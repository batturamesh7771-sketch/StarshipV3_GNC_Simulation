classdef Starship3DVisualizer < handle
    % STARSHIP3DVISUALIZER High-Fidelity Multi-Body Real-Time Mission Control
    %
    % Manages the 3D multi-viewport GUI:
    %   - Viewport 1: 3D Multi-Vehicle Flight Screen (Starship Upper Stage + Booster Flip & Boostback)
    %   - Viewport 2: Global 3D Earth Dual-Track Orbit & RTLS Map
    %   - Viewport 3: Dual-Vehicle Real-Time Telemetry Panels (Ship + Booster)
    %   - Viewport 4: Dual-Vehicle Propellant & AGM Status Gauges
    
    properties
        fig
        ax3D
        axTrack
        axTelemetry
        axGauges
        
        % 3D Transformation Groups
        tformWorld
        tformBooster
        tformShip
        tformSatellite
        tformFlameBooster
        tformFlameShip
        
        % Visual Handles
        patchBooster
        patchShipBody
        patchShipNose
        patchSatellite
        patchSolarLeft
        patchSolarRight
        patchFlameBooster
        patchFlameShip
        patchEarth
        trajLineShip
        trajLineBooster
        markerShip
        markerBooster
        
        % Dual Telemetry Text Handles (Ship)
        txtShipClock
        txtShipVel
        txtShipAlt
        txtShipStatus
        
        % Dual Telemetry Text Handles (Booster)
        txtBoosterVel
        txtBoosterDownrange
        txtBoosterAlt
        txtBoosterStatus
        
        % Gauge Handles
        barShipProp
        barBoosterProp
        txtShipPropVal
        txtBoosterPropVal
        
        % State Tracking
        isStaged = false
        isPayloadDeployed = false
        stagingTime = 140.0
        deployDist = 0.0
    end
    
    methods
        function obj = Starship3DVisualizer()
            obj.initDashboard();
        end
        
        function initDashboard(obj)
            % Create main dark-themed window
            obj.fig = figure('Name', 'STARSHIP V3 DUAL-VEHICLE MISSION CONTROL & RTLS TRACKING', ...
                             'NumberTitle', 'off', ...
                             'Color', [0.01 0.01 0.03], ...
                             'Units', 'normalized', ...
                             'Position', [0.02, 0.04, 0.96, 0.90], ...
                             'MenuBar', 'none', ...
                             'ToolBar', 'none', ...
                             'Visible', 'on');
            
            % Left Panel: 3D Real-Time Flight Viewport (Width: 62% of figure)
            obj.ax3D = axes('Parent', obj.fig, ...
                            'Position', [0.015, 0.02, 0.61, 0.95], ...
                            'Color', [0.012 0.012 0.025], ...
                            'XColor', 'none', ...
                            'YColor', 'none', ...
                            'ZColor', 'none');
            hold(obj.ax3D, 'on');
            axis(obj.ax3D, 'equal');
            xlim(obj.ax3D, [-110, 110]);
            ylim(obj.ax3D, [-110, 110]);
            zlim(obj.ax3D, [-110, 110]);
            
            % Cinematic chase camera angle
            campos(obj.ax3D, [165, -170, 80]);
            camtarget(obj.ax3D, [-5, 0, 5]);
            camva(obj.ax3D, 40);
            
            % Deep space background starfield
            rng(101);
            numStars = 140;
            sx = (rand(1, numStars) - 0.5) * 450;
            sy = (rand(1, numStars) - 0.5) * 450;
            sz = (rand(1, numStars) - 0.5) * 450;
            plot3(obj.ax3D, sx, sy, sz, '.', 'Color', [0.8 0.88 1.0], 'MarkerSize', 4);
            
            % Multi-point studio lighting
            light('Parent', obj.ax3D, 'Position', [220, -160, 160], 'Style', 'infinite', 'Color', [1.0 1.0 1.0]);
            light('Parent', obj.ax3D, 'Position', [-160, 160, 90], 'Style', 'infinite', 'Color', [0.6 0.7 0.9]);
            light('Parent', obj.ax3D, 'Position', [0, -120, -160], 'Style', 'infinite', 'Color', [0.4 0.4 0.5]);
            
            title(obj.ax3D, 'STARSHIP V3 DUAL-VEHICLE FLIGHT VIEWPORT — INERTIAL TRACKING', ...
                  'Color', [0 0.9 1.0], 'FontSize', 13, 'FontWeight', 'bold');
            
            % Build 3D Rocket Models & Transformation Hierarchy
            obj.build3DModels();
            
            % Right Top Panel: 3D Global Orbital & RTLS Dual Track
            obj.axTrack = axes('Parent', obj.fig, ...
                               'Position', [0.65, 0.67, 0.33, 0.29], ...
                               'Color', [0.02 0.02 0.04], ...
                               'XColor', [0.3 0.3 0.3], ...
                               'YColor', [0.3 0.3 0.3], ...
                               'ZColor', [0.3 0.3 0.3]);
            hold(obj.axTrack, 'on');
            view(obj.axTrack, [125, 20]);
            axis(obj.axTrack, 'equal');
            grid(obj.axTrack, 'on');
            title(obj.axTrack, 'GLOBAL 3D DUAL TRAJECTORY TRACK (LEO & RTLS)', ...
                  'Color', [0.2 0.95 0.4], 'FontSize', 11, 'FontWeight', 'bold');
            obj.buildEarthTrack();
            
            % Right Middle Panel: Digital Ticking Dual-Vehicle Telemetry Readouts
            obj.axTelemetry = axes('Parent', obj.fig, ...
                                   'Position', [0.65, 0.31, 0.33, 0.32], ...
                                   'Color', [0.03 0.04 0.06], ...
                                   'XColor', 'none', ...
                                   'YColor', 'none', ...
                                   'ZColor', 'none');
            hold(obj.axTelemetry, 'on');
            xlim(obj.axTelemetry, [0, 100]);
            ylim(obj.axTelemetry, [0, 100]);
            obj.initTelemetryPanel();
            
            % Right Bottom Panel: Dual Propellant & Flight Status Gauges
            obj.axGauges = axes('Parent', obj.fig, ...
                                'Position', [0.65, 0.03, 0.33, 0.25], ...
                                'Color', [0.03 0.04 0.06], ...
                                'XColor', 'none', ...
                                'YColor', 'none', ...
                                'ZColor', 'none');
            hold(obj.axGauges, 'on');
            xlim(obj.axGauges, [0, 100]);
            ylim(obj.axGauges, [0, 100]);
            obj.initGaugePanel();
        end
        
        function build3DModels(obj)
            % Root world transform group (centered on upper stage)
            obj.tformWorld = hgtransform('Parent', obj.ax3D);
            
            % Stage 1 (Booster) Transform
            obj.tformBooster = hgtransform('Parent', obj.tformWorld);
            
            % Stage 2 (Starship Upper Stage) Transform
            obj.tformShip = hgtransform('Parent', obj.tformWorld);
            
            % Payload Satellite Transform (Parented to Ship)
            obj.tformSatellite = hgtransform('Parent', obj.tformShip);
            
            % Exhaust Plume Transforms
            obj.tformFlameBooster = hgtransform('Parent', obj.tformBooster);
            obj.tformFlameShip = hgtransform('Parent', obj.tformShip);
            
            r_rocket = 4.5;
            
            % --- MODEL A: Super Heavy Booster (Stainless Steel Cylinder + Grid Fins) ---
            [Xb, Yb, Zb] = cylinder(r_rocket, 32);
            Zb = Zb * 70.0 - 60.0; % Z from -60 to +10
            obj.patchBooster = surf(Xb, Yb, Zb, 'Parent', obj.tformBooster, ...
                                    'FaceColor', [0.82 0.84 0.88], ...
                                    'EdgeColor', [0.3 0.35 0.4], ...
                                    'FaceAlpha', 1.0, ...
                                    'SpecularStrength', 0.9, ...
                                    'DiffuseStrength', 0.85, ...
                                    'AmbientStrength', 0.7);
            
            % Booster 4 Grid Fins
            for i = 1:4
                ang = (i-1) * pi/2;
                xf = [r_rocket, r_rocket+3.5, r_rocket+3.5, r_rocket];
                yf = [-0.2, -0.2, 0.2, 0.2];
                zf = [2, 2, 8, 8];
                R_grid = [cos(ang) -sin(ang); sin(ang) cos(ang)];
                xy_rot = R_grid * [xf; yf];
                patch(xy_rot(1,:), xy_rot(2,:), zf, [0.15 0.17 0.20], ...
                      'Parent', obj.tformBooster, 'EdgeColor', 'none', ...
                      'AmbientStrength', 0.7);
            end
            
            % --- MODEL B: Starship Upper Stage (Cylinder + Nose Cone + Flaps) ---
            [Xs, Ys, Zs] = cylinder(r_rocket, 32);
            Zs = Zs * 35.0 + 10.0; % Z from +10 to +45
            obj.patchShipBody = surf(Xs, Ys, Zs, 'Parent', obj.tformShip, ...
                                     'FaceColor', [0.88 0.90 0.95], ...
                                     'EdgeColor', [0.3 0.35 0.4], ...
                                     'FaceAlpha', 1.0, ...
                                     'SpecularStrength', 0.95, ...
                                     'DiffuseStrength', 0.85, ...
                                     'AmbientStrength', 0.75);
            
            % Heat Shield Belly Tiles (Dark on -X side)
            [X_tile, Y_tile, Z_tile] = cylinder(r_rocket * 1.01, 32);
            Z_tile = Z_tile * 35.0 + 10.0;
            X_tile(X_tile > 0) = NaN;
            surf(X_tile, Y_tile, Z_tile, 'Parent', obj.tformShip, ...
                 'FaceColor', [0.10 0.10 0.12], 'EdgeColor', 'none', ...
                 'AmbientStrength', 0.6);
            
            % Aerodynamic Nose Cone
            [Xn, Yn, Zn] = cylinder([r_rocket, 0.05], 32);
            Zn = Zn * 15.0 + 45.0;
            obj.patchShipNose = surf(Xn, Yn, Zn, 'Parent', obj.tformShip, ...
                                     'FaceColor', [0.88 0.90 0.95], ...
                                     'EdgeColor', [0.3 0.35 0.4], ...
                                     'FaceAlpha', 1.0, ...
                                     'SpecularStrength', 0.95, ...
                                     'DiffuseStrength', 0.85, ...
                                     'AmbientStrength', 0.75);
            
            % Starship Control Flaps
            patch([-r_rocket, -r_rocket-3.5, -r_rocket-2.5, -r_rocket], [0 0 0 0], [48 48 55 55], ...
                  [0.12 0.12 0.15], 'Parent', obj.tformShip, 'EdgeColor', 'none', 'AmbientStrength', 0.7);
            patch([r_rocket, r_rocket+3.5, r_rocket+2.5, r_rocket], [0 0 0 0], [48 48 55 55], ...
                  [0.85 0.87 0.92], 'Parent', obj.tformShip, 'EdgeColor', 'none', 'AmbientStrength', 0.7);
            patch([-r_rocket, -r_rocket-4.5, -r_rocket-3.5, -r_rocket], [0 0 0 0], [12 12 22 22], ...
                  [0.12 0.12 0.15], 'Parent', obj.tformShip, 'EdgeColor', 'none', 'AmbientStrength', 0.7);
            patch([r_rocket, r_rocket+4.5, r_rocket+3.5, r_rocket], [0 0 0 0], [12 12 22 22], ...
                  [0.85 0.87 0.92], 'Parent', obj.tformShip, 'EdgeColor', 'none', 'AmbientStrength', 0.7);
            
            % --- MODEL C: Payload Satellite ---
            sat_z = 48.0;
            [Xsat, Ysat, Zsat] = obj.makeCube(4.0, 4.0, 5.0, 0, 0, sat_z);
            obj.patchSatellite = patch('Vertices', [Xsat, Ysat, Zsat], ...
                                       'Faces', [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8], ...
                                       'FaceColor', [1.0 0.82 0.10], ...
                                       'EdgeColor', [0.4 0.3 0.0], ...
                                       'Parent', obj.tformSatellite, ...
                                       'SpecularStrength', 1.0, ...
                                       'AmbientStrength', 0.85);
            
            [Xsl, Ysl, Zsl] = obj.makeCube(1.5, 9.0, 0.3, 0, -7.0, sat_z);
            obj.patchSolarLeft = patch('Vertices', [Xsl, Ysl, Zsl], ...
                                       'Faces', [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8], ...
                                       'FaceColor', [0.0 0.50 1.0], ...
                                       'EdgeColor', [0.2 0.8 1.0], ...
                                       'Parent', obj.tformSatellite, ...
                                       'AmbientStrength', 0.85);
            
            [Xsr, Ysr, Zsr] = obj.makeCube(1.5, 9.0, 0.3, 0, 7.0, sat_z);
            obj.patchSolarRight = patch('Vertices', [Xsr, Ysr, Zsr], ...
                                        'Faces', [1 2 3 4; 5 6 7 8; 1 2 6 5; 2 3 7 6; 3 4 8 7; 4 1 5 8], ...
                                        'FaceColor', [0.0 0.50 1.0], ...
                                        'EdgeColor', [0.2 0.8 1.0], ...
                                        'Parent', obj.tformSatellite, ...
                                        'AmbientStrength', 0.85);
            
            % --- EXHAUST FLAMES ---
            % Booster Plume
            [Xf, Yf, Zf] = cylinder([4.2, 0.6], 24);
            Zf = -Zf * 35.0 - 60.0;
            obj.patchFlameBooster = surf(Xf, Yf, Zf, 'Parent', obj.tformFlameBooster, ...
                                         'FaceColor', [1.0 0.45 0.05], ...
                                         'EdgeColor', 'none', ...
                                         'FaceAlpha', 0.85, ...
                                         'AmbientStrength', 0.95);
            
            % Starship Vacuum Raptor Plume
            [Xsf, Ysf, Zsf] = cylinder([4.0, 7.5], 24);
            Zsf = 10.0 - Zsf * 28.0;
            obj.patchFlameShip = surf(Xsf, Ysf, Zsf, 'Parent', obj.tformFlameShip, ...
                                      'FaceColor', [0.0 0.80 1.0], ...
                                      'EdgeColor', 'none', ...
                                      'FaceAlpha', 0.80, ...
                                      'AmbientStrength', 0.95, ...
                                      'Visible', 'off');
        end
        
        function [X, Y, Z] = makeCube(~, dx, dy, dz, cx, cy, cz)
            hx = dx/2; hy = dy/2; hz = dz/2;
            X = cx + [-hx; hx; hx; -hx; -hx; hx; hx; -hx];
            Y = cy + [-hy; -hy; hy; hy; -hy; -hy; hy; hy];
            Z = cz + [-hz; -hz; -hz; -hz; hz; hz; hz; hz];
        end
        
        function buildEarthTrack(obj)
            [Xe, Ye, Ze] = sphere(30);
            Re_km = 6378.137;
            surf(obj.axTrack, Xe * Re_km, Ye * Re_km, Ze * Re_km, ...
                 'FaceColor', [0.05 0.15 0.35], 'EdgeColor', [0.1 0.3 0.6], ...
                 'FaceAlpha', 0.85);
            
            % Trajectory lines: Ship (Green), Booster (Orange/Magenta)
            obj.trajLineShip = animatedline(obj.axTrack, 'Color', [0.0 1.0 0.3], ...
                                            'LineWidth', 2.2, 'DisplayName', 'Starship Orbital Path');
            obj.trajLineBooster = animatedline(obj.axTrack, 'Color', [1.0 0.4 0.1], ...
                                               'LineWidth', 2.2, 'DisplayName', 'Booster RTLS Path');
            
            obj.markerShip = plot3(obj.axTrack, 0, 0, Re_km, 'p', ...
                                   'MarkerSize', 12, 'MarkerFaceColor', [0.0 0.9 1.0], ...
                                   'MarkerEdgeColor', 'w');
            obj.markerBooster = plot3(obj.axTrack, 0, 0, Re_km, 's', ...
                                      'MarkerSize', 9, 'MarkerFaceColor', [1.0 0.5 0.1], ...
                                      'MarkerEdgeColor', 'w');
            
            % Target Orbit Ring (250 km)
            ang = linspace(0, 2*pi, 100);
            R_orb = Re_km + 250.0;
            plot3(obj.axTrack, R_orb * cos(ang), R_orb * sin(ang), zeros(size(ang)), ...
                  '--', 'Color', [1.0 0.75 0.0], 'LineWidth', 1.5);
        end
        
        function initTelemetryPanel(obj)
            % Header
            text(obj.axTelemetry, 4, 92, 'DUAL-VEHICLE TELEMETRY BROADCAST', ...
                 'Color', [0 0.9 1.0], 'FontSize', 11, 'FontWeight', 'bold');
            
            % Column 1: Starship Upper Stage
            text(obj.axTelemetry, 4, 78, '[STARSHIP UPPER STAGE]', 'Color', [0.2 0.95 0.4], 'FontSize', 9.5, 'FontWeight', 'bold');
            text(obj.axTelemetry, 4, 62, 'CLOCK:', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtShipClock = text(obj.axTelemetry, 22, 62, 'T+ 000.0 s', 'Color', [0.0 0.95 0.9], 'FontSize', 9.5, 'FontWeight', 'bold');
            
            text(obj.axTelemetry, 4, 46, 'SPEED:', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtShipVel = text(obj.axTelemetry, 22, 46, '0000.0 m/s', 'Color', [0.2 0.95 0.3], 'FontSize', 9.5, 'FontWeight', 'bold');
            
            text(obj.axTelemetry, 4, 30, 'ALT (MSL):', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtShipAlt = text(obj.axTelemetry, 22, 30, '000.00 km', 'Color', [1.0 0.85 0.1], 'FontSize', 9.5, 'FontWeight', 'bold');
            
            text(obj.axTelemetry, 4, 14, 'STATUS:', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtShipStatus = text(obj.axTelemetry, 22, 14, 'LIFTOFF', 'Color', [0.2 0.9 1.0], 'FontSize', 9, 'FontWeight', 'bold');
            
            % Column 2: Super Heavy Booster
            text(obj.axTelemetry, 54, 78, '[SUPER HEAVY BOOSTER]', 'Color', [1.0 0.55 0.1], 'FontSize', 9.5, 'FontWeight', 'bold');
            text(obj.axTelemetry, 54, 62, 'REENTRY V:', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtBoosterVel = text(obj.axTelemetry, 74, 62, '0000.0 m/s', 'Color', [1.0 0.5 0.1], 'FontSize', 9.5, 'FontWeight', 'bold');
            
            text(obj.axTelemetry, 54, 46, 'DOWNRANGE:', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtBoosterDownrange = text(obj.axTelemetry, 74, 46, '000.0 km', 'Color', [1.0 0.85 0.1], 'FontSize', 9.5, 'FontWeight', 'bold');
            
            text(obj.axTelemetry, 54, 30, 'ALT (MSL):', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtBoosterAlt = text(obj.axTelemetry, 74, 30, '000.00 km', 'Color', [0.2 0.95 0.3], 'FontSize', 9.5, 'FontWeight', 'bold');
            
            text(obj.axTelemetry, 54, 14, 'STATUS:', 'Color', [0.7 0.7 0.7], 'FontSize', 8.5);
            obj.txtBoosterStatus = text(obj.axTelemetry, 74, 14, 'ACTIVE STACK', 'Color', [1.0 0.5 0.1], 'FontSize', 9, 'FontWeight', 'bold');
        end
        
        function initGaugePanel(obj)
            text(obj.axGauges, 4, 90, 'VEHICLE PROPELLANT RESERVE GAUGES', ...
                 'Color', [0 0.9 1.0], 'FontSize', 10.5, 'FontWeight', 'bold');
            
            % Starship Propellant Gauge Box
            text(obj.axGauges, 8, 74, 'SHIP PROPELLANT', 'Color', [0.8 0.8 0.8], 'FontSize', 8.5, 'FontWeight', 'bold');
            rectangle(obj.axGauges, 'Position', [10, 16, 35, 52], ...
                      'EdgeColor', [0.4 0.4 0.5], 'FaceColor', [0.08 0.09 0.12], 'LineWidth', 1.2);
            obj.barShipProp = rectangle(obj.axGauges, 'Position', [10, 16, 35, 52], ...
                                        'FaceColor', [0.2 0.9 0.4], 'EdgeColor', 'none');
            obj.txtShipPropVal = text(obj.axGauges, 18, 8, '100.0 %', ...
                                      'Color', [0.2 0.9 0.4], 'FontSize', 9, 'FontWeight', 'bold');
            
            % Booster Propellant Gauge Box
            text(obj.axGauges, 56, 74, 'BOOSTER PROPELLANT', 'Color', [0.8 0.8 0.8], 'FontSize', 8.5, 'FontWeight', 'bold');
            rectangle(obj.axGauges, 'Position', [58, 16, 35, 52], ...
                      'EdgeColor', [0.4 0.4 0.5], 'FaceColor', [0.08 0.09 0.12], 'LineWidth', 1.2);
            obj.barBoosterProp = rectangle(obj.axGauges, 'Position', [58, 16, 35, 52], ...
                                           'FaceColor', [1.0 0.5 0.1], 'EdgeColor', 'none');
            obj.txtBoosterPropVal = text(obj.axGauges, 66, 8, '100.0 %', ...
                                         'Color', [1.0 0.5 0.1], 'FontSize', 9, 'FontWeight', 'bold');
        end
        
        function update(obj, t, stateShip, stateBooster, pitchDegShip, pitchDegBooster, ...
                        propShipPct, propBoosterPct, statusShip, statusBooster, isCutoff, isBoosterLanded)
            
            % State unpacking
            px_s = stateShip(1); pz_s = stateShip(3);
            v_mag_s = norm(stateShip(4:6));
            alt_km_s = pz_s / 1000.0;
            
            px_b = stateBooster(1); pz_b = stateBooster(3);
            v_mag_b = norm(stateBooster(4:6));
            alt_km_b = pz_b / 1000.0;
            
            pitchRadShip = deg2rad(90.0 - pitchDegShip);
            flameJitter = 0.85 + 0.3 * rand();
            
            % Center Viewport 1 tracking around Starship
            M_pitch = makehgtform('yrotate', pitchRadShip);
            set(obj.tformWorld, 'Matrix', M_pitch);
            
            % --- 1. MULTI-BODY TRANSFORMS ---
            if t < obj.stagingTime
                obj.isStaged = false;
                set(obj.tformBooster, 'Matrix', eye(4));
                set(obj.tformShip, 'Matrix', eye(4));
                
                set(obj.tformFlameBooster, 'Matrix', makehgtform('scale', [flameJitter, flameJitter, flameJitter]));
                set(obj.patchFlameBooster, 'Visible', 'on');
                set(obj.patchFlameShip, 'Visible', 'off');
            else
                if ~obj.isStaged
                    obj.isStaged = true;
                    set(obj.patchFlameShip, 'Visible', 'on');
                end
                
                % Ship remains centered
                set(obj.tformShip, 'Matrix', eye(4));
                
                % Booster relative position & independent orientation
                dt_stage = t - obj.stagingTime;
                relX = (px_b - px_s) * 0.05;
                relZ = (pz_b - pz_s) * 0.05;
                
                % Bound visual separation inside viewport frame
                visX = max(-65.0, min(65.0, relX - 1.2 * dt_stage^1.3));
                visZ = max(-65.0, min(65.0, relZ - 1.8 * dt_stage^1.3));
                
                pitchRadBooster = deg2rad(pitchDegBooster - pitchDegShip);
                M_booster = makehgtform('translate', [visX, 0, visZ], 'yrotate', pitchRadBooster);
                set(obj.tformBooster, 'Matrix', M_booster);
                
                % Booster Flame (Active during Boostback & Landing)
                if strcmp(statusBooster, '13-RAPTOR BOOSTBACK BURN') || strcmp(statusBooster, '3-RAPTOR LANDING BURN')
                    set(obj.patchFlameBooster, 'Visible', 'on');
                    set(obj.tformFlameBooster, 'Matrix', makehgtform('scale', [flameJitter*1.2, flameJitter*1.2, flameJitter*1.4]));
                else
                    set(obj.patchFlameBooster, 'Visible', 'off');
                end
                
                % Ship Flame
                if ~isCutoff
                    set(obj.tformFlameShip, 'Matrix', makehgtform('scale', [flameJitter, flameJitter, flameJitter]));
                    set(obj.patchFlameShip, 'Visible', 'on');
                else
                    set(obj.patchFlameShip, 'Visible', 'off');
                end
            end
            
            % --- 2. SATELLITE DEPLOYMENT ANIMATION ---
            if isCutoff
                obj.isPayloadDeployed = true;
                obj.deployDist = min(32.0, obj.deployDist + 2.0);
                
                M_sat = makehgtform('translate', [0, 0, obj.deployDist], 'zrotate', 0.1 * t);
                set(obj.tformSatellite, 'Matrix', M_sat);
                set(obj.patchShipNose, 'FaceAlpha', 0.3);
            end
            
            % --- 3. DUAL TELEMETRY READOUTS ---
            set(obj.txtShipClock, 'String', sprintf('T+ %05.1f s', t));
            set(obj.txtShipVel, 'String', sprintf('%05.1f m/s', v_mag_s));
            set(obj.txtShipAlt, 'String', sprintf('%05.2f km', alt_km_s));
            set(obj.txtShipStatus, 'String', statusShip);
            
            set(obj.txtBoosterVel, 'String', sprintf('%05.1f m/s', v_mag_b));
            set(obj.txtBoosterDownrange, 'String', sprintf('%05.1f km', px_b / 1000.0));
            set(obj.txtBoosterAlt, 'String', sprintf('%05.2f km', alt_km_b));
            set(obj.txtBoosterStatus, 'String', statusBooster);
            
            % --- 4. DUAL PROPELLANT GAUGES ---
            fillShipH = max(0.5, 52.0 * (propShipPct / 100.0));
            set(obj.barShipProp, 'Position', [10, 16, 35, fillShipH]);
            set(obj.txtShipPropVal, 'String', sprintf('%05.1f %%', propShipPct));
            
            fillBoosterH = max(0.5, 52.0 * (propBoosterPct / 100.0));
            set(obj.barBoosterProp, 'Position', [58, 16, 35, fillBoosterH]);
            set(obj.txtBoosterPropVal, 'String', sprintf('%05.1f %%', propBoosterPct));
            
            % --- 5. GLOBAL 3D DUAL TRACK ---
            Re_km = 6378.137;
            r_s = Re_km + alt_km_s;
            phi_s = px_s / (Re_km * 1000.0);
            trackX_s = r_s * sin(phi_s);
            trackY_s = stateShip(2) / 1000.0;
            trackZ_s = r_s * cos(phi_s);
            addpoints(obj.trajLineShip, trackX_s, trackY_s, trackZ_s);
            set(obj.markerShip, 'XData', trackX_s, 'YData', trackY_s, 'ZData', trackZ_s);
            
            if t >= obj.stagingTime
                r_b = Re_km + alt_km_b;
                phi_b = px_b / (Re_km * 1000.0);
                trackX_b = r_b * sin(phi_b);
                trackY_b = stateBooster(2) / 1000.0;
                trackZ_b = r_b * cos(phi_b);
                addpoints(obj.trajLineBooster, trackX_b, trackY_b, trackZ_b);
                set(obj.markerBooster, 'XData', trackX_b, 'YData', trackY_b, 'ZData', trackZ_b);
            end
            
            drawnow limitrate;
        end
        
        function saveSnapshot(obj, filename)
            if exist(filename, 'file'); try delete(filename); catch; end; end; exportgraphics(obj.fig, filename, 'Resolution', 200);
            fprintf('[SUCCESS] Dual-Vehicle Mission Control Dashboard saved to: %s\n', filename);
        end
    end
end
