# Prompt 01: Phase 1 Ascent GNC Protocol

## Context & Role Assignment
> **Role:** Principal Guidance, Navigation, and Control (GNC) Flight Software Engineer specializing in high-energy, multi-stage heavy-lift vehicles.  
> **Task:** Build a complete, flight-ready, object-oriented 3-DOF / pseudo-6-DOF launch ascent simulation platform for the SpaceX Starship V3 full-stack configuration from scratch in MATLAB.

---

## System Access Initialization
1. Initialize MATLAB workspace cleanly (`clear all`, `close all`, `clc`).
2. Create root directory `StarshipV3_GNC_Simulation`.
3. Establish topocentric downrange-altitude frame:
   - $X$: Downrange East (m)
   - $Y$: Downrange North (m)
   - $Z$: Altitude above sea level (m)

---

## Technical Specifications & Mathematical Models

### 1. Vehicle Dynamics & Environment (`StarshipV3Vehicle.m`)
- Full Stack: $5,000\,\text{t}$ total wet mass ($m_0$).
- Super Heavy Booster: 33 Raptor 3 engines ($90.6\,\text{MN}$ total thrust, $I_{\text{sp}} = 330\,\text{s}$ SL / $350\,\text{s}$ vac).
- Starship Upper Stage: $1,500\,\text{t}$ wet mass, 6 Raptor engines ($24.0\,\text{MN}$ vac thrust, $I_{\text{sp}} = 380\,\text{s}$).
- Aerodynamics: US Standard Atmosphere 1976 $\rho(z) = \rho_0 e^{-z / H}$, speed of sound $c(z)$, piecewise continuous Mach $C_d(M)$.

### 2. Navigation System (`NavigationSystem.m`)
- 50 Hz Extended Kalman Filter (EKF) fusing noisy IMU accelerometers, gyros (with bias states), and GPS tracking.
- Welford $O(1)$ sample variance calculation.

### 3. Guidance Computer (`GuidanceComputer.m`)
- Phase 1 (0–35 km): Liftoff vertical climb, Antigravity Module $\gamma = 1.20$, 85% throttle.
- Phase 2 (35–85 km): Gravity turn pitchover, AGM $\gamma$ linearly decaying from $1.20 \to 0.0$.
- Phase 3 (85–250 km): Vacuum insertion using Linear Tangent Guidance (LTG/PEG) to $250\,\text{km}$ circular LEO at $7,752\,\text{m/s}$.

### 4. Flight Controller (`FlightController.m`)
- 100 Hz TVC PID loop with $[-5^\circ, +5^\circ]$ mechanical hard stops and first-order actuator lag ($\tau = 0.05\,\text{s}$).

### 5. Master Simulation Executive (`MasterAscentSimulator.m`)
- Fixed-step RK4 numerical integration ($dt = 0.1\,\text{s}$, $T=0$ to $450\,\text{s}$).
- Staging sequence at $T+140\,\text{s}$ or booster burnout.
- Export 4-panel publication-ready telemetry dashboard `StarshipV3_Ascent_Telemetry.png`.
