classdef StarshipV3Vehicle < handle
    % STARSHIPV3VEHICLE SpaceX Starship V3 Block 3 Heavy-Lift Launch Vehicle
    %
    % Models mass properties, multi-engine thrust envelopes (33 Raptor 3 Booster,
    % 6 Raptor 3 Ship), atmospheric properties, Mach-dependent drag, and grid-fin aerodynamics.
    
    properties
        % Vehicle Structural Constants (Block 3 Stretched Architecture)
        m_booster_dry   = 230000.0;     % Booster dry mass (kg)
        m_booster_prop  = 3650000.0;    % Booster propellant mass (kg)
        m_ship_dry      = 120000.0;     % Upper stage dry mass (kg)
        m_ship_prop     = 1500000.0;    % Upper stage propellant mass (kg)
        m_payload       = 150000.0;     % Payload mass to LEO (kg)
        
        % Dimensions
        diameter        = 9.0;          % Vehicle diameter (m)
        height_booster  = 72.0;         % Booster height (m)
        height_ship     = 52.0;         % Ship height (m)
        A_ref           = 63.62;        % Cross-sectional reference area (m^2)
        A_grid_fins     = 18.0;         % Grid fin effective control area (m^2)
        
        % Propulsion: Super Heavy Booster (33x Raptor 3)
        num_engines_booster = 33;
        num_engines_boostback = 13;     % 13 center engines used for Boostback burn
        num_engines_landing   = 3;      % 3 center engines used for Landing burn
        thrust_raptor_sl    = 2.75e6;   % Sea level thrust per Raptor 3 (N) (~280 tf)
        thrust_raptor_vac   = 2.95e6;   % Vacuum thrust per Raptor 3 (N)
        Isp_booster_sl      = 330.0;    % Sea level specific impulse (s)
        Isp_booster_vac     = 350.0;    % Vacuum specific impulse (s)
        
        % Propulsion: Starship Upper Stage (3x SL + 3x Vacuum Raptor 3)
        num_engines_ship    = 6;
        thrust_ship_vac     = 24.0e6;   % Total vacuum thrust (N) (6x Raptor 3)
        Isp_ship_vac        = 380.0;    % Specific impulse (s)
        
        % Environmental & Planetary Constants (WGS-84 / Standard Earth)
        g0                  = 9.80665;      % Standard gravity (m/s^2)
        Re                  = 6378137.0;    % Earth equatorial radius (m)
        mu                  = 3.986004418e14; % Earth gravitational parameter (m^3/s^2)
        omega_earth         = 7.292115e-5;  % Earth rotation rate (rad/s)
        
        % US Standard Atmosphere 1976 Constants
        rho0                = 1.225;        % Sea-level atmospheric density (kg/m^3)
        H_scale             = 7200.0;       % Atmospheric scale height (m)
        gamma_air           = 1.4;          % Specific heat ratio
        R_gas               = 287.058;      % Specific gas constant (J/kg*K)
        T0                  = 288.15;       % Sea-level temperature (K)
        lapse_rate          = 0.0065;       % Tropospheric lapse rate (K/m)
        
        % Current Configuration State
        currentStage        = 1;            % 1 = Full Stack, 2 = Starship Upper Stage
    end
    
    properties (Dependent)
        m0_total            % Liftoff wet mass (kg)
        m_ship_wet          % Ship wet mass at staging (kg)
        T_booster_max_sl    % Maximum booster sea-level thrust (N)
        T_booster_max_vac   % Maximum booster vacuum thrust (N)
    end
    
    methods
        function obj = StarshipV3Vehicle(stage)
            if nargin > 0
                obj.currentStage = stage;
            end
        end
        
        function val = get.m0_total(obj)
            val = obj.m_booster_dry + obj.m_booster_prop + ...
                  obj.m_ship_dry + obj.m_ship_prop + obj.m_payload;
        end
        
        function val = get.m_ship_wet(obj)
            val = obj.m_ship_dry + obj.m_ship_prop + obj.m_payload;
        end
        
        function val = get.T_booster_max_sl(obj)
            val = obj.num_engines_booster * obj.thrust_raptor_sl;
        end
        
        function val = get.T_booster_max_vac(obj)
            val = obj.num_engines_booster * obj.thrust_raptor_vac;
        end
        
        function [rho, p, T] = getAtmosphericProperties(obj, altitude)
            h = max(0.0, altitude);
            if h <= 11000.0
                T = obj.T0 - obj.lapse_rate * h;
                p = 101325.0 * (T / obj.T0)^(obj.g0 / (obj.lapse_rate * obj.R_gas));
                rho = p / (obj.R_gas * T);
            elseif h <= 25000.0
                T = 216.65;
                p11 = 22632.1;
                p = p11 * exp(-obj.g0 * (h - 11000.0) / (obj.R_gas * T));
                rho = p / (obj.R_gas * T);
            else
                rho = obj.rho0 * exp(-h / obj.H_scale);
                p = rho * obj.R_gas * 216.65;
                T = 216.65;
            end
        end
        
        function rho = getAtmosphericDensity(obj, altitude)
            [rho, ~, ~] = obj.getAtmosphericProperties(altitude);
        end
        
        function c = getSpeedOfSound(obj, altitude)
            [~, ~, T] = obj.getAtmosphericProperties(altitude);
            c = sqrt(obj.gamma_air * obj.R_gas * max(100.0, T));
        end
        
        function Cd = getDragCoefficient(~, mach)
            % Piecewise continuous transonic and supersonic drag model
            if mach < 0.8
                Cd = 0.28 + 0.05 * (mach / 0.8)^2;
            elseif mach < 1.05
                % Transonic rise
                t_val = (mach - 0.8) / (1.05 - 0.8);
                Cd = 0.33 + 0.35 * (3*t_val^2 - 2*t_val^3);
            elseif mach < 1.3
                % Transonic peak
                t_val = (mach - 1.05) / (1.3 - 1.05);
                Cd = 0.68 - 0.15 * t_val;
            elseif mach < 5.0
                % Supersonic decay
                Cd = 0.53 * (1.3 / mach)^0.45;
            else
                % Hypersonic asymptote
                Cd = 0.26 + 0.04 / (mach - 4.0);
            end
        end
        
        function Cd_grid = getGridFinDrag(~, mach, aoa_deg)
            % Grid fin drag and stabilization response
            base_cd = 0.65;
            if mach > 1.0
                base_cd = 0.95 / sqrt(max(1.1, mach^2 - 1.0));
            end
            Cd_grid = base_cd + 0.8 * sind(abs(aoa_deg))^2;
        end
    end
end
