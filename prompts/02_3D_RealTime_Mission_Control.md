# Prompt 02: 3D Real-Time Animated Mission Control Dashboard

## Mission Objective
Refactor the entire SpaceX Starship V3 simulation engine to generate a high-fidelity, real-time 3D Visual Animation Dashboard alongside ticking telemetry readout systems.

---

## Operational Instructions
1. Rewrite `MasterAscentSimulator.m` and construct `Starship3DVisualizer.m`.
2. Implement OpenGL 3D multi-viewport dashboard:
   - **Viewport 1 (3D Real-Time Flight Screen):**
     * 3D geometric rocket model (Super Heavy Booster cylinder + Starship Upper Stage fuselage + nose cone + flaps).
     * Physical pitch/yaw/roll attitude maneuvers in 3D space.
     * Dynamic exhaust plumes with engine thrust flickering.
     * Uncoupling and tumbling first-stage booster at $T+140\,\text{s}$.
     * Payload satellite deployment from nose cone upon orbital insertion.
   - **Viewport 2A (Global 3D Earth Orbit Track):**
     * 3D Earth coordinate globe with animated trajectory line (`animatedline`).
     * Real-time vehicle orbital marker.
   - **Viewport 2B (Digital Telemetry Readout Box):**
     * Real-time ticking mission clock (`T+ MET`), inertial velocity, altitude MSL, and GNC status.
   - **Viewport 2C (Sliding Vertical Gauges):**
     * Propellant remaining percentage bar.
     * Antigravity factor $\gamma$ gauge.
3. Save high-resolution final snapshot to `StarshipV3_3D_Mission_Success.png`.
