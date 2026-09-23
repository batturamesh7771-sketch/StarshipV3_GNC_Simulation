# Prompt 03: Dual-Vehicle Parallel Tracking & Advanced GNC Pipeline Upgrade

## Mission Mandate
Completely overhaul the current workspace to upgrade the GNC architectures from simplified equations to a high-fidelity, dual-vehicle parallel tracking framework matching real-world SpaceX Starship V3 flight operations ($dt = 0.05\,\text{s}$, $T=0$ to $450\,\text{s}$).

---

## Detailed Component Specifications

### 1. Guidance Computer Upgrade (`GuidanceComputer.m`)
- **Max-Q Throttle Control:** Continuously monitor dynamic pressure $q = \frac{1}{2} \rho v^2$. Throttle down 33 engines by 30% when approaching threshold curve ($T+25\,\text{s}$ to $T+42\,\text{s}$) to suppress structural loads. Restore 100% throttle above $15\,\text{km}$.
- **Block 3 Stretched Vehicle Mass:** Booster dry mass = $230,000\,\text{kg}$, Upper stage dry mass = $120,000\,\text{kg}$, Liftoff mass = $5,500\,\text{t}$. Independent fuel depletion loops.
- **Iterative Closed-Loop Guidance:** Recalculate target thrust vector directions every 1.0 second based on remaining velocity-to-be-gained ($\Delta \mathbf{v}_{\text{go}}$).

### 2. Flight Controller Upgrade (`FlightController.m`)
- **Soviet-Style Hot-Staging Matrix:** At $T+140\,\text{s}$, keep 5 center booster engines firing to hold propellant at tank bottom, while igniting upper stage engines attached. Apply 0.7-second downward force vector ($4.5\,\text{MN}$) and tipping moment against booster forward dome.
- **2nd-Order Actuator Lag:** Mechanical time constant $\tau = 0.08\,\text{s}$, natural frequency $\omega_n = 25\,\text{rad/s}$, damping $\zeta = 0.70$. Slew rate limit $10^\circ/\text{s}$, strict TVC hard limits $\pm 5.0^\circ$.

### 3. Dual-Vehicle Parallel Engine (`MasterAscentSimulator.m`)
- **Vehicle A (Starship Upper Stage):** Continues along primary trajectory using PEG to circularize into $250\,\text{km}$ LEO at $7,752\,\text{m/s}$.
- **Vehicle B (Super Heavy Booster):** Rapid $180^\circ$ RCS flip, 13-Raptor retro-propulsive boostback burn, hypersonic/supersonic grid-fin glide, and 3-engine landing burn targeting launchpad $(0,0)$.

### 4. Broadcast Visual Dashboard Enhancement
- Viewport 1 (3D Flight Path): Multi-body choreography (Starship accelerating into space + Booster flipping with orange boostback plume).
- Viewport 2 (Global Map): Dual trailing tracking lines across 3D rotating Earth globe.
- Viewport 3 (Dual Telemetry Boxes): Dual columns of real-time digital readouts for Ship and Booster.
- Viewport 4: Dual propellant reserve gauges.
