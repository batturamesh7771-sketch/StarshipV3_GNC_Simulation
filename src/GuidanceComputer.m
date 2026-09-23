classdef GuidanceComputer < handle
    % GUIDANCECOMPUTER Advanced Multi-Vehicle Iterative Closed-Loop Guidance
    %
    % Manages:
    %   1. Vehicle A (Starship Upper Stage):
    %      - Max-Q dynamic pressure throttle modulation
    %      - Closed-Loop Powered Explicit Guidance (PEG) targeting 250 km LEO (7,752 m/s)
    %      - Iterative 1.0-second Delta-V recalculation
    %   2. Vehicle B (Super Heavy Booster):
    %      - Hot-Staging & RCS 180-deg flip sequence
    %      - 13-engine retro-propulsive Boostback burn targeting (0,0)
    %      - Aerodynamic grid-fin descent & 3-engine landing burn
    
    properties
        % Target Orbit Parameters (250 km circular LEO)
        r_target        = 6378137.0 + 250000.0; % Target geocentric radius (m)
        v_target        = 7752.0;               % Target circular orbital velocity (m/s)
        h_target        = 250000.0;             % Target altitude (m)
        
        % Dynamic Pressure (Max-Q) Limits
        q_max_limit     = 32000.0;              % Dynamic pressure throttle trigger (Pa)
        isMaxQThrottled = false;
        
        % Closed-Loop PEG State
        lastGuidanceUpdate = -1.0;              % Last closed-loop recalc time (s)
        guidanceInterval   = 1.0;               % Closed-loop update period (s)
        A_peg              = 0.0;               % PEG linear tangent constant A
        B_peg              = 0.0;               % PEG linear tangent constant B
        T_go               = 180.0;             % Estimated time-to-go (s)
        deltaV_go          = 4500.0;            % Remaining velocity-to-be-gained (m/s)
        
        % Booster RTLS Guidance State
        boosterPhase       = 'BOOST_PHASE';     % 'FLIP', 'BOOSTBACK', 'DESCENT', 'LANDING', 'TOUCHDOWN'
        boostbackTargetVx  = -320.0;            % Return horizontal speed (m/s)
    end
    
    methods
        function obj = GuidanceComputer()
            obj.lastGuidanceUpdate = -1.0;
        end
        
        function [theta_cmd, gamma_agm, throttle, phase_num, status_str] = computeShipGuidance(obj, t, state_nav, mass, q_bar, vehicle)
            % COMPUTESHIPGUIDANCE Closed-loop guidance for Starship Full Stack / Upper Stage
            %
            % State vector: [posX_geo; posY_geo; velX_geo; velY_geo; pitch_inertial]
            r_curr = norm(state_nav(1:2));
            alt = r_curr - vehicle.Re;
            v_curr = norm(state_nav(3:4));
            
            % --- 1. ASCENT PHASING ---
            if alt < 35000.0 && t < 140.0
                phase_num = 1;
                gamma_agm = 1.20; % Antigravity liftoff assist
                
                % Gravity turn pitch profile
                if alt < 1200.0
                    theta_cmd = pi/2.0; % Pure vertical liftoff
                    status_str = 'LIFTOFF VERTICAL';
                else
                    theta_cmd = pi/2.0 - 0.40 * ((alt - 1200.0) / (35000.0 - 1200.0))^0.65;
                    status_str = 'GRAVITY TURN';
                end
                
                % Max-Q Throttle Control Logic
                if (q_bar > obj.q_max_limit || (t >= 25.0 && t <= 42.0)) && alt < 15000.0
                    throttle = 0.70; % Throttle down by 30% to suppress structural load
                    obj.isMaxQThrottled = true;
                    status_str = 'MAX-Q THROTTLE BACK (70%)';
                else
                    throttle = 1.00;
                    obj.isMaxQThrottled = false;
                end
                
            elseif alt < 85000.0 && t < 140.0
                phase_num = 2;
                % Smoothly ramp AGM factor gamma from 1.20 down to 0.0
                alpha_trans = (alt - 35000.0) / (85000.0 - 35000.0);
                gamma_agm = 1.20 * (1.0 - alpha_trans);
                
                theta_cmd = pi/2.0 - 0.40 - 0.55 * (alpha_trans^0.8);
                throttle = 1.00;
                status_str = 'HIGH-ALT ACCELERATION';
                
            else
                phase_num = 3;
                gamma_agm = 0.00; % Antigravity fully disengaged in vacuum
                throttle = 1.00;
                
                % --- ITERATIVE CLOSED-LOOP PEG GUIDANCE (1-Second Cycle) ---
                if (t - obj.lastGuidanceUpdate) >= obj.guidanceInterval || obj.lastGuidanceUpdate < 0
                    obj.updatePEG(t, state_nav, mass, vehicle);
                    obj.lastGuidanceUpdate = t;
                end
                
                % Compute target pitch angle from Linear Tangent Law: tan(theta) = A + B * t_go
                t_burn = max(0.0, obj.T_go - (t - obj.lastGuidanceUpdate));
                tan_pitch = obj.A_peg + obj.B_peg * (obj.T_go - t_burn);
                theta_cmd = atan(tan_pitch);
                
                % Limit pitch angle to prevent extreme unphysical attitudes
                theta_cmd = max(deg2rad(0.0), min(deg2rad(45.0), theta_cmd));
                status_str = 'PEG CLOSED-LOOP';
            end
        end
        
        function updatePEG(obj, t, state_nav, mass, vehicle)
            % Update Powered Explicit Guidance parameters based on Delta-V remaining
            v_curr = norm(state_nav(3:4));
            r_curr = norm(state_nav(1:2));
            vr_curr = (state_nav(1)*state_nav(3) + state_nav(2)*state_nav(4)) / r_curr;
            
            % Velocity to be gained
            obj.deltaV_go = max(0.0, obj.v_target - v_curr);
            
            % Thrust & Mass Flow
            Thrust = vehicle.thrust_ship_vac;
            Isp = vehicle.Isp_ship_vac;
            m_dot = Thrust / (Isp * vehicle.g0);
            
            % Rocket equation estimation of Time-to-go
            acc_curr = Thrust / mass;
            if acc_curr > 0.1
                tau = mass / m_dot;
                % Taylor expansion / Tsiolkovsky inversion: dV = Isp*g0*ln(1 / (1 - T_go/tau))
                ratio = exp(-obj.deltaV_go / (Isp * vehicle.g0));
                obj.T_go = max(1.0, tau * (1.0 - ratio));
            else
                obj.T_go = 30.0;
            end
            
            % Radial velocity and position constraints
            h_err = obj.r_target - r_curr;
            vr_des = max(-50.0, min(100.0, 0.05 * h_err));
            dvr = vr_des - vr_curr;
            
            % Linear tangent coefficients
            obj.A_peg = (dvr + (vehicle.mu/(r_curr^2) - v_curr^2/r_curr) * obj.T_go) / max(100.0, obj.deltaV_go);
            obj.B_peg = -obj.A_peg / max(10.0, obj.T_go);
        end
        
        function [theta_booster, throttle_booster, status_booster] = computeBoosterGuidance(obj, t, state_booster, mass_booster, vehicle)
            % COMPUTEBOOSTERGUIDANCE RTLS Boostback, Grid-Fin Glide & Landing Guidance
            %
            % State vector: [x; y; z; vx; vy; vz]
            x = state_booster(1);
            z = state_booster(3);
            vx = state_booster(4);
            vz = state_booster(6);
            
            t_after_stage = t - 140.0;
            
            if t_after_stage < 4.0
                % Step 1: Cold-Gas RCS 180-deg Flip Maneuver
                obj.boosterPhase = 'FLIP';
                pitch_progress = min(1.0, t_after_stage / 4.0);
                theta_booster = deg2rad(45.0 + 135.0 * pitch_progress); % Pitching back toward 180 deg
                throttle_booster = 0.0;
                status_booster = 'RCS 180-DEG FLIP';
                
            elseif t_after_stage < 42.0 && vx > obj.boostbackTargetVx
                % Step 2: 13-Raptor Retro-Propulsive Boostback Burn
                obj.boosterPhase = 'BOOSTBACK';
                theta_booster = deg2rad(175.0); % Pointing retrograde toward launchpad
                throttle_booster = 1.0;
                status_booster = '13-RAPTOR BOOSTBACK BURN';
                
            elseif z > 25000.0
                % Step 3: High-Altitude Coast & Atmosphere Alignment
                obj.boosterPhase = 'COAST_ENTRY';
                theta_booster = deg2rad(150.0);
                throttle_booster = 0.0;
                status_booster = 'APOGEE ENTRY COAST';
                
            elseif z > 2500.0
                % Step 4: Aerodynamic Grid-Fin Controlled Descent
                obj.boosterPhase = 'DESCENT';
                % Steer to glide toward x = 0
                target_pitch_deg = 180.0 - 30.0 * max(-1.0, min(1.0, x / 10000.0));
                theta_booster = deg2rad(target_pitch_deg);
                throttle_booster = 0.0;
                status_booster = 'GRID-FIN ENTRY GLIDE';
                
            elseif z > 20.0 && vz < -5.0
                % Step 5: 3-Raptor Landing Burn & Tower Catch
                obj.boosterPhase = 'LANDING';
                theta_booster = deg2rad(90.0); % Vertical deceleration
                
                % Suicidal/hover deceleration control
                v_des = -max(2.0, sqrt(2.0 * 20.0 * z));
                throttle_booster = max(0.4, min(1.0, 0.7 + 0.05 * (v_des - vz)));
                status_booster = '3-RAPTOR LANDING BURN';
                
            else
                % Touchdown / Catch Complete
                obj.boosterPhase = 'TOUCHDOWN';
                theta_booster = deg2rad(90.0);
                throttle_booster = 0.0;
                status_booster = 'TOWER CATCH COMPLETE';
            end
        end
    end
end
