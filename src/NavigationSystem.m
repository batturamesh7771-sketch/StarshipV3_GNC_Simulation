classdef NavigationSystem < handle
    % NAVIGATIONSYSTEM Dual-Vehicle Extended Kalman Filter (EKF)
    %
    % Tracks 3D/geocentric state vectors for:
    %   1. Starship Full-Stack / Upper Stage [x; y; z; vx; vy; vz]
    %   2. Super Heavy Booster [x; y; z; vx; vy; vz]
    
    properties
        % State Vectors
        x_est_ship      = zeros(6, 1);  % [x; y; z; vx; vy; vz]
        x_est_booster   = zeros(6, 1);  % [x; y; z; vx; vy; vz]
        
        % Covariance Matrices
        P_ship          = eye(6);
        P_booster       = eye(6);
        
        % Process and Measurement Noise
        Q               = eye(6);
        R               = eye(6);
        
        % Sensor Biases & Noise Parameters
        accel_bias      = [0.012; 0.008; -0.015]; % m/s^2
        gyro_bias       = 0.0005;                % rad/s
        dt_nav          = 0.05;                  % 20 Hz filter rate
        prev_update_t   = 0.0;
        
        % Welford O(1) Running Statistics
        welford_count   = 0;
        welford_mean    = zeros(6, 1);
        welford_M2      = zeros(6, 1);
    end
    
    methods
        function obj = NavigationSystem(init_state, dt)
            if nargin > 0 && ~isempty(init_state)
                obj.x_est_ship(1:length(init_state)) = init_state;
                obj.x_est_booster(1:length(init_state)) = init_state;
            end
            if nargin > 1
                obj.dt_nav = dt;
            end
            
            % Initialize covariances
            obj.P_ship = diag([100, 100, 100, 1.0, 1.0, 1.0]);
            obj.P_booster = diag([100, 100, 100, 1.0, 1.0, 1.0]);
            
            obj.Q = diag([0.1, 0.1, 0.1, 0.5, 0.5, 0.5]) * 0.01;
            obj.R = diag([25.0, 25.0, 25.0, 0.2, 0.2, 0.2]);
        end
        
        function updateShip(obj, t, true_state_6d, noisy_accel)
            dt = obj.dt_nav;
            
            % EKF Predict Step
            F = eye(6);
            F(1,4) = dt; F(2,5) = dt; F(3,6) = dt;
            
            x_pred = F * obj.x_est_ship;
            x_pred(4:6) = x_pred(4:6) + (noisy_accel - obj.accel_bias) * dt;
            
            P_pred = F * obj.P_ship * F' + obj.Q;
            
            % Measurement with GPS/Radar noise
            z_meas = true_state_6d + [randn(3,1)*4.0; randn(3,1)*0.3];
            
            % Update Step
            H = eye(6);
            y_res = z_meas - H * x_pred;
            S = H * P_pred * H' + obj.R;
            K = (P_pred * H') / S;
            
            obj.x_est_ship = x_pred + K * y_res;
            obj.P_ship = (eye(6) - K * H) * P_pred;
            
            % Welford Sample Variance Accumulator
            obj.welford_count = obj.welford_count + 1;
            d1 = obj.x_est_ship - obj.welford_mean;
            obj.welford_mean = obj.welford_mean + d1 / obj.welford_count;
            d2 = obj.x_est_ship - obj.welford_mean;
            obj.welford_M2 = obj.welford_M2 + d1 .* d2;
        end
        
        function updateBooster(obj, t, true_state_6d, noisy_accel)
            dt = obj.dt_nav;
            F = eye(6);
            F(1,4) = dt; F(2,5) = dt; F(3,6) = dt;
            
            x_pred = F * obj.x_est_booster;
            x_pred(4:6) = x_pred(4:6) + (noisy_accel - obj.accel_bias) * dt;
            P_pred = F * obj.P_booster * F' + obj.Q;
            
            z_meas = true_state_6d + [randn(3,1)*3.0; randn(3,1)*0.2];
            H = eye(6);
            y_res = z_meas - H * x_pred;
            S = H * P_pred * H' + obj.R;
            K = (P_pred * H') / S;
            
            obj.x_est_booster = x_pred + K * y_res;
            obj.P_booster = (eye(6) - K * H) * P_pred;
        end
        
        function st = getShipState(obj)
            st = obj.x_est_ship;
        end
        
        function st = getBoosterState(obj)
            st = obj.x_est_booster;
        end
        
        function var_est = getVariance(obj)
            if obj.welford_count > 1
                var_est = obj.welford_M2 / (obj.welford_count - 1);
            else
                var_est = zeros(6, 1);
            end
        end
    end
end
