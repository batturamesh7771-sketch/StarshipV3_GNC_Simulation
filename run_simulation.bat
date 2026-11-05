@echo off
echo =====================================================================
echo  SPACEX STARSHIP V3 DUAL-VEHICLE PARALLEL GNC SIMULATOR LAUNCHER
echo =====================================================================
echo Launching MATLAB R2026a real-time 3D simulation...
"E:\Program Files\MATLAB\R2026a\bin\matlab.exe" -nosplash -r "cd('%~dp0'); addpath('src'); MasterAscentSimulator;"
echo Simulation complete.
pause
