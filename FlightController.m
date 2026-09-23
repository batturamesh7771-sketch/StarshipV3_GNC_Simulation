classdef FlightController < handle
    % FLIGHTCONTROLLER TVC Gimbal Actuator Dynamics & Hot-Staging Controller
    %
    % Models:
    %   - 2nd-order hydraulic actuator dynamics with mechanical lag (tau = 0.08s)
    %   - Maximum gimbal slew rate saturation (10 deg/s)
    %   - Strict physical gimbal deflection hard stops (+/- 5.0 deg)
    %   - Hot-staging plume impingement disturbance suppression
    
    properties
        % Actuator Mechanical Parameters
        tau_act         = 0.08;         % Time constant lag (s)
        omega_n         = 25.0;         % Natural frequency (rad/s)
        zeta            = 0.70;         % Damping ratio
        slew_rate_max   = deg2rad(10.0);% Max gimbal slew rate (10 deg/s in rad/s)
        gimbal_limit    = deg2rad(5.0); % Strict +/- 5.0 deg mechanical hard limit
        
        % State Variables (2nd order: delta and delta_dot)
        delta_actual    = 0.0;          % Current gimbal angle (rad)
        delta_dot       = 0.0;          % Current gimbal angular rate (rad/s)
        
        % PID Controller Gains
        Kp              = 3.8;          % Proportional gain
        Ki              = 0.35;         % Integral gain
        Kd              = 2.2;          % Derivative gain
        
        % Controller Internal State
        err_integral    = 0.0;
        prev_err        = 0.0;
        prev_time       = 0.0;
        current_pitch   = pi/2.0;       % Vehicle attitude angle (rad)
        current_rate    = 0.0;          % Pitch rate (rad/s)
        
        % Hot-Staging Disturbance Tracking
        hotStageStartTime = 140.0;
        hotStageDuration  = 0.70;       % 0.7 second plume blast
    end
    
    methods
        function obj = FlightController(dt_init, theta_init)
            if nargin > 1
                obj.current_pitch = theta_init;
            end
            obj.prev_time = 0.0;
            obj.delta_actual = 0.0;
            obj.delta_dot = 0.0;
        end
        
        function [thrust_dir_rad, delta_out, current_rate_out, F_impinge, M_impinge] = update(obj, t, theta_cmd_rad, theta_actual_rad)
            % Compute time delta
            if obj.prev_time == 0.0
                dt = 0.05;
            else
                dt = max(0.001, min(0.1, t - obj.prev_time));
            end
            obj.prev_time = t;
            
            % --- 1. HOT-STAGING TRANSIENT MATRIX & DISTURBANCE ---
            F_impinge = 0.0;
            M_impinge = 0.0;
            if t >= obj.hotStageStartTime && t < (obj.hotStageStartTime + obj.hotStageDuration)
                % Asymmetrical downward plume blast on booster dome
                t_blast = t - obj.hotStageStartTime;
                blast_factor = sin(pi * t_blast / obj.hotStageDuration);
                F_impinge = 4.5e6 * blast_factor;   % 4.5 MN downward force
                M_impinge = 9.2e6 * blast_factor;   % 9.2 MN*m asymmetrical tipping moment
            end
            
            % --- 2. PID ATTITUDE TRACKING LOOP ---
            err = theta_cmd_rad - theta_actual_rad;
            obj.err_integral = obj.err_integral + err * dt;
            % Anti-windup clamping
            obj.err_integral = max(-0.2, min(0.2, obj.err_integral));
            
            err_deriv = (err - obj.prev_err) / dt;
            obj.prev_err = err;
            
            % Commanded raw TVC gimbal angle
            delta_cmd = obj.Kp * err + obj.Ki * obj.err_integral + obj.Kd * err_deriv;
            
            % If hot-staging blast active, feedforward TVC counter-torque
            if M_impinge > 0
                delta_cmd = delta_cmd - deg2rad(2.8); % Counter-gimbal to suppress tip-force
            end
            
            % Apply hard gimbal deflection limits (+/- 5.0 deg)
            delta_cmd = max(-obj.gimbal_limit, min(obj.gimbal_limit, delta_cmd));
            
            % --- 3. 2ND-ORDER ACTUATOR DYNAMICS & SLEW RATE LIMITING ---
            % d^2(delta)/dt^2 = omega_n^2 * (delta_cmd - delta) - 2*zeta*omega_n*delta_dot
            delta_ddot = (obj.omega_n^2) * (delta_cmd - obj.delta_actual) - 2.0 * obj.zeta * obj.omega_n * obj.delta_dot;
            
            % Slew rate update with strict 10 deg/s saturation
            obj.delta_dot = obj.delta_dot + delta_ddot * dt;
            obj.delta_dot = max(-obj.slew_rate_max, min(obj.slew_rate_max, obj.delta_dot));
            
            % Actuator position update
            obj.delta_actual = obj.delta_actual + obj.delta_dot * dt;
            obj.delta_actual = max(-obj.gimbal_limit, min(obj.gimbal_limit, obj.delta_actual));
            
            % --- 4. VEHICLE ATTITUDE DYNAMICS ---
            % Pitch moment from gimbal thrust + disturbance moment
            I_vehicle = 8.5e7; % Pitch moment of inertia (kg*m^2)
            control_torque = 90.6e6 * sin(obj.delta_actual) * 35.0; % TVC lever arm
            total_torque = control_torque - M_impinge;
            
            alpha_pitch = total_torque / I_vehicle;
            obj.current_rate = obj.current_rate + alpha_pitch * dt;
            obj.current_rate = max(-0.15, min(0.15, obj.current_rate)); % Damped pitch rate
            
            obj.current_pitch = theta_actual_rad + obj.current_rate * dt;
            
            % Output thrust direction
            thrust_dir_rad = obj.current_pitch + obj.delta_actual;
            delta_out = obj.delta_actual;
            current_rate_out = obj.current_rate;
        end
    end
end
