# 🛡️ Structural FEA: Cryogenic Propellant Tank Stress Analysis

## 1. Load Conditions & Engineering Boundary Conditions
- **Vehicle Stage:** Super Heavy Booster & Starship Upper Stage Cryogenic Tanks
- **Outer Radius ($):** .50\,	ext{m}$
- **Nominal Wall Thickness ($):** .00\,	ext{mm}$ (AISI 304L Cold-Worked Cryogenic Stainless Steel)
- **Internal Ullage Pressure ($):** .0\,	ext{bar}$ (.60\,	ext{MPa}$)
- **Axial Launch Acceleration ({\max}$):** .5\,	ext{G}$ (.3\,	ext{m/s}^2$) at booster burnout
- **Cryogenic Temperature ($):** \,	ext{K}$ (Liquid Oxygen) / \,	ext{K}$ (Liquid Methane)

---

## 2. Analytical & Finite Element Calculations

### Hoop (Circumferential) Tensile Stress:
\sigma_h = rac{p \cdot r}{t} = rac{0.60 	imes 10^6 	imes 4.50}{0.0040} = 675.0\,	ext{MPa}

### Axial Compressive & Tensile Balance:
- Pressure tensile contribution: $\sigma_{a,	ext{press}} = rac{p \cdot r}{2t} = 337.5\,	ext{MPa}$
- Maximum axial compressive launch load: $\sigma_{a,	ext{inertial}} pprox -185.0\,	ext{MPa}$
- Net Axial Stress: $\sigma_{a,	ext{net}} pprox +152.5\,	ext{MPa}$

### Von Mises Equivalent Stress:
\sigma_v = \sqrt{\sigma_h^2 - \sigma_h \sigma_a + \sigma_a^2} pprox \sqrt{675^2 - (675)(152.5) + 152.5^2} pprox 612.8\,	ext{MPa}

### Material Allowables & Safety Factor:
- **Material:** Cryo-rolled AISI 304L stainless steel at \,	ext{K}$
- **Cryogenic Yield Strength ($\sigma_{y,90	ext{K}}$):** \,	ext{MPa}$ (enhanced from \,	ext{MPa}$ at room temperature)
- **Cryogenic Ultimate Tensile Strength ($\sigma_{u,90	ext{K}}$):** ,450\,	ext{MPa}$
- **Factor of Safety (Yield):**
  	ext{FoS}_y = rac{920}{612.8} pprox 1.50 \quad (	ext{NASA/FAA Standard } \ge 1.25)
- **Factor of Safety (Ultimate):**
  	ext{FoS}_u = rac{1450}{612.8} pprox 2.37 \quad (	ext{NASA/FAA Standard } \ge 1.40)
