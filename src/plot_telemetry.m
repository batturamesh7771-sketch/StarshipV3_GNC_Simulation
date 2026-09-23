function plot_telemetry(t_log, ship_log, booster_log, event_log)
    % PLOT_TELEMETRY High-Fidelity 4-Panel Dual-Vehicle Telemetry Visualizer
    %
    % Generates publication-quality figures capturing the complete multi-body
    % ascent, hot-staging, booster boostback return, and orbital insertion profile.
    
    fig = figure('Name', 'STARSHIP V3 DUAL-VEHICLE ASCENT & RTLS TELEMETRY', ...
                 'NumberTitle', 'off', ...
                 'Color', [0.03 0.04 0.06], ...
                 'Units', 'normalized', ...
                 'Position', [0.05, 0.05, 0.90, 0.88], ...
                 'Visible', 'on');
    
    % Panel 1: Downrange vs Altitude (Multi-Body Trajectory)
    ax1 = subplot(2, 2, 1);
    hold(ax1, 'on'); grid(ax1, 'on');
    set(ax1, 'Color', [0.06 0.07 0.10], 'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8]);
    plot(ax1, ship_log.x/1000, ship_log.z/1000, 'LineWidth', 2.2, 'Color', [0.0 0.9 1.0], 'DisplayName', 'Starship Orbit Track');
    plot(ax1, booster_log.x/1000, booster_log.z/1000, '--', 'LineWidth', 2.2, 'Color', [1.0 0.45 0.1], 'DisplayName', 'Super Heavy RTLS Track');
    plot(ax1, 0, 0, 'p', 'MarkerSize', 14, 'MarkerFaceColor', [0.2 1.0 0.3], 'MarkerEdgeColor', 'w', 'DisplayName', 'Launch/Catch Tower (0,0)');
    yline(ax1, 250.0, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Target LEO (250 km)');
    title(ax1, 'MULTI-BODY FLIGHT PROFILE (DOWNRANGE VS ALTITUDE)', 'Color', [0 0.9 1.0], 'FontSize', 11, 'FontWeight', 'bold');
    xlabel(ax1, 'Downrange Distance X (km)', 'Color', 'w');
    ylabel(ax1, 'Geocentric Altitude Z (km)', 'Color', 'w');
    legend(ax1, 'TextColor', 'w', 'Location', 'northwest', 'Color', [0.1 0.12 0.16]);
    
    % Panel 2: Velocity Profiles vs MET
    ax2 = subplot(2, 2, 2);
    hold(ax2, 'on'); grid(ax2, 'on');
    set(ax2, 'Color', [0.06 0.07 0.10], 'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8]);
    plot(ax2, t_log, ship_log.v, 'LineWidth', 2.0, 'Color', [0.2 0.95 0.4], 'DisplayName', 'Starship Inertial Speed');
    plot(ax2, booster_log.t, booster_log.v, '--', 'LineWidth', 2.0, 'Color', [1.0 0.5 0.1], 'DisplayName', 'Booster Speed');
    yline(ax2, 7752.0, 'g--', 'LineWidth', 1.5, 'DisplayName', 'Orbital Velocity (7,752 m/s)');
    xline(ax2, 140.0, 'm-.', 'LineWidth', 1.5, 'DisplayName', 'Hot-Staging (T+140s)');
    title(ax2, 'VELOCITY PROFILE VS MISSION ELAPSED TIME', 'Color', [0 0.9 1.0], 'FontSize', 11, 'FontWeight', 'bold');
    xlabel(ax2, 'Mission Elapsed Time (s)', 'Color', 'w');
    ylabel(ax2, 'Velocity Magnitude (m/s)', 'Color', 'w');
    legend(ax2, 'TextColor', 'w', 'Location', 'northwest', 'Color', [0.1 0.12 0.16]);
    
    % Panel 3: Dynamic Pressure & Throttle % (Max-Q Notch)
    ax3 = subplot(2, 2, 3);
    hold(ax3, 'on'); grid(ax3, 'on');
    set(ax3, 'Color', [0.06 0.07 0.10], 'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8]);
    yyaxis(ax3, 'left');
    plot(ax3, t_log, ship_log.q/1000, 'LineWidth', 2.0, 'Color', [1.0 0.3 0.3], 'DisplayName', 'Dynamic Pressure (kPa)');
    ylabel(ax3, 'Dynamic Pressure q (kPa)', 'Color', [1.0 0.3 0.3]);
    ax3.YColor = [1.0 0.4 0.4];
    
    yyaxis(ax3, 'right');
    plot(ax3, t_log, ship_log.throttle * 100, 'LineWidth', 2.0, 'Color', [0.0 0.8 1.0], 'DisplayName', 'Throttle %');
    ylabel(ax3, 'Engine Throttle (%)', 'Color', [0.0 0.8 1.0]);
    ax3.YColor = [0.0 0.8 1.0];
    
    title(ax3, 'MAX-Q THROTTLE CONTROL & AERODYNAMIC LOADS', 'Color', [0 0.9 1.0], 'FontSize', 11, 'FontWeight', 'bold');
    xlabel(ax3, 'Mission Elapsed Time (s)', 'Color', 'w');
    
    % Panel 4: Dual Vehicle Propellant Reserves
    ax4 = subplot(2, 2, 4);
    hold(ax4, 'on'); grid(ax4, 'on');
    set(ax4, 'Color', [0.06 0.07 0.10], 'XColor', [0.8 0.8 0.8], 'YColor', [0.8 0.8 0.8]);
    plot(ax4, t_log, ship_log.prop_pct, 'LineWidth', 2.2, 'Color', [0.2 0.95 0.4], 'DisplayName', 'Starship Propellant %');
    plot(ax4, booster_log.t, booster_log.prop_pct, '--', 'LineWidth', 2.2, 'Color', [1.0 0.5 0.1], 'DisplayName', 'Booster Propellant %');
    title(ax4, 'DUAL-VEHICLE PROPELLANT CONSUMPTION', 'Color', [0 0.9 1.0], 'FontSize', 11, 'FontWeight', 'bold');
    xlabel(ax4, 'Mission Elapsed Time (s)', 'Color', 'w');
    ylabel(ax4, 'Propellant Remaining (%)', 'Color', 'w');
    legend(ax4, 'TextColor', 'w', 'Location', 'northeast', 'Color', [0.1 0.12 0.16]);
    
    % Export plot
    outPlot = 'StarshipV3_Ascent_Telemetry.png';
    if exist(outPlot, 'file'); try delete(outPlot); catch; end; end; exportgraphics(fig, outPlot, 'Resolution', 200);
    fprintf('[SUCCESS] 4-Panel telemetry dashboard exported to: %s\n', outPlot);
end
