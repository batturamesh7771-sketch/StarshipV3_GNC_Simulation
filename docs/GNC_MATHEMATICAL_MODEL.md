# SpaceX Starship V3 GNC Mathematical Model & Physics Derivations

This document details the mathematical framework, equations of motion, aerodynamic models, guidance algorithms, and filter formulations implemented in the Starship V3 simulation engine.

---

## 1. 3D Equations of Motion (Spherical Earth Frame)

The vehicle state is defined in the topocentric downrange-altitude frame:
$$\mathbf{r} = \begin{bmatrix} x \\ y \\ z \end{bmatrix}, \quad \mathbf{v} = \begin{bmatrix} v_x \\ v_y \\ v_z \end{bmatrix}$$

The geocentric radius is:
$$r = R_E + z$$

### Differential Equations:
$$\dot{x} = v_x, \quad \dot{y} = v_y, \quad \dot{z} = v_z$$

$$\dot{v}_x = \frac{T_x - D_x}{m} - \frac{v_x v_z}{r}$$
$$\dot{v}_y = \frac{T_y - D_y}{m} - \frac{v_y v_z}{r}$$
$$\dot{v}_z = \frac{T_z - D_z}{m} - (1 - \gamma) \frac{\mu}{r^2} + \frac{v_x^2 + v_y^2}{r}$$

where:
- $\mu = 3.986004418 \times 10^{14}\,\text{m}^3/\text{s}^2$ (Standard Earth Gravitational Parameter)
- $R_E = 6,378,137\,\text{m}$ (WGS-84 Equatorial Radius)
- $\gamma$ is the Antigravity Module (AGM) coupling factor ($\gamma = 1.20$ at liftoff, decaying to $0.0$ in vacuum).

---

## 2. Atmospheric Density & Aerodynamic Drag

### US Standard Atmosphere (1976 Model):
- Troposphere ($z \le 11\,\text{km}$):
  $$T(z) = T_0 - L z, \quad p(z) = p_0 \left(1 - \frac{L z}{T_0}\right)^{\frac{g_0}{R L}}, \quad \rho(z) = \frac{p(z)}{R T(z)}$$
- Stratosphere / Upper Atmosphere ($z > 11\,\text{km}$):
  $$\rho(z) = \rho_0 e^{-\frac{z}{H_{\text{scale}}}}$$

### Dynamic Pressure & Aerodynamic Forces:
$$q = \frac{1}{2} \rho v_{\text{rel}}^2$$
$$\mathbf{D} = q A_{\text{ref}} C_d(M) \hat{\mathbf{v}}_{\text{rel}}$$

where $C_d(M)$ is the piecewise continuous transonic-to-hypersonic drag coefficient function:
- $M < 0.8$: $C_d = 0.28 + 0.05 \left(\frac{M}{0.8}\right)^2$
- $0.8 \le M < 1.05$: Transonic wave drag ramp up to $C_{d,\text{peak}} \approx 0.68$
- $1.05 \le M < 5.0$: Supersonic decay $C_d = 0.53 \left(\frac{1.3}{M}\right)^{0.45}$
- $M \ge 5.0$: Hypersonic asymptote $C_d = 0.26 + \frac{0.04}{M - 4.0}$

---

## 3. Closed-Loop Powered Explicit Guidance (PEG)

For vacuum orbital circularization ($250\,\text{km}$ at $7,752\,\text{m/s}$), the guidance computer calculates the velocity-to-be-gained:
$$\Delta \mathbf{v}_{\text{go}} = \mathbf{v}_{\text{target}} - \mathbf{v}_{\text{nav}}$$

The Linear Tangent Law commands the pitch angle $\theta(t)$:
$$\tan \theta(t) = A + B (t_{\text{go}} - t)$$

Coefficients $A$ and $B$ are updated iteratively every $1.0\,\text{s}$ using Taylor series inversion of the rocket equation:
$$t_{\text{go}} = \tau \left(1 - \exp\left(-\frac{\Delta v_{\text{go}}}{I_{\text{sp}} g_0}\right)\right), \quad \tau = \frac{m}{\dot{m}}$$

---

## 4. 2nd-Order Actuator & TVC Dynamics

The hydraulic engine gimbal actuator is modeled as a 2nd-order transfer function with mechanical lag $\tau = 0.08\,\text{s}$:
$$\ddot{\delta} = \omega_n^2 (\delta_{\text{cmd}} - \delta) - 2 \zeta \omega_n \dot{\delta}$$

Subject to strict physical rate and angle saturations:
$$|\dot{\delta}| \le 10^\circ/\text{s}, \quad |\delta| \le 5.0^\circ$$

---

## 5. Dual-Vehicle Extended Kalman Filter (EKF)

State vector $\mathbf{x} = [x, y, z, v_x, v_y, v_z]^T$.
- State transition matrix:
  $$\mathbf{F} = \begin{bmatrix} \mathbf{I}_{3\times 3} & \Delta t \mathbf{I}_{3\times 3} \\ \mathbf{0}_{3\times 3} & \mathbf{I}_{3\times 3} \end{bmatrix}$$
- Predict & Update equations:
  $$\hat{\mathbf{x}}_{k|k-1} = \mathbf{F} \hat{\mathbf{x}}_{k-1} + \mathbf{B} \mathbf{u}_k$$
  $$\mathbf{P}_{k|k-1} = \mathbf{F} \mathbf{P}_{k-1} \mathbf{F}^T + \mathbf{Q}$$
  $$\mathbf{K}_k = \mathbf{P}_{k|k-1} \mathbf{H}^T (\mathbf{H} \mathbf{P}_{k|k-1} \mathbf{H}^T + \mathbf{R})^{-1}$$
  $$\hat{\mathbf{x}}_k = \hat{\mathbf{x}}_{k|k-1} + \mathbf{K}_k (\mathbf{z}_k - \mathbf{H} \hat{\mathbf{x}}_{k|k-1})$$
