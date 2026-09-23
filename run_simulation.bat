@echo off
echo =====================================================================
echo  SPACEX STARSHIP V3 DUAL-VEHICLE PARALLEL GNC SIMULATOR LAUNCHER
echo =====================================================================
echo Launching MATLAB real-time 3D simulation...
matlab -batch "cd('%~dp0'); addpath('src'); MasterAscentSimulator;"
echo Simulation complete.
pause
