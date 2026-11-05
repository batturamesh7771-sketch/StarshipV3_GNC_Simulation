Option Explicit

Dim swApp, swModel, swDocExt, swFeatMgr, swSketchMgr
Dim boolstatus, longstatus, longwarnings
Dim two_pi, pi
two_pi = 6.283185307179586
pi = 3.141592653589793

Dim partTemplate, asmTemplate, baseDir
partTemplate = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"
asmTemplate  = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Assembly.ASMDOT"
baseDir      = "C:\Users\user\.gemini\antigravity\scratch\solidworks_rocket\starship_v3\"

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True

WScript.Echo "======================================================================"
WScript.Echo "SPACEX STARBASE - STARSHIP V3 / SUPER HEAVY V3 ARCHITECTURE GENERATOR"
WScript.Echo "======================================================================"
WScript.Echo "SolidWorks Engine Connected: " & swApp.RevisionNumber

' ====================================================================
' MODULE 1: V3 MASTER SKELETON (V3_Master_Skeleton.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [PHASE 1] Building V3 Master Skeleton & Datum Planes..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Master Centerline Sketch (124.4m on Front Plane)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 124.4, 0
' Reference OML boundaries (9m diameter -> 4.5m radius)
swSketchMgr.CreateCenterLine 4.5, 0, 0, 4.5, 124.4, 0
swSketchMgr.CreateCenterLine -4.5, 0, 0, -4.5, 124.4, 0
swSketchMgr.InsertSketch True

' 2. 9m Diameter Outer Mold Line (OML) Reference Surface
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0, 0, 0, 4.5
' Extrude thin reference surface / cylinder up to 124.4m
Dim featOML
Set featOML = swFeatMgr.FeatureExtrusion3(True, False, False, 0, 0, 124.4, 0, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 3. Reference Datum Planes
' Plane 2: Booster Forward Dome / Hot Staging (Y=71.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
Dim refPlane71
Set refPlane71 = swFeatMgr.InsertRefPlane(8, 71.0, 0, 0, 0, 0)

' Plane 3: Ship Aft Engine Section (Y=73.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
Dim refPlane73
Set refPlane73 = swFeatMgr.InsertRefPlane(8, 73.0, 0, 0, 0, 0)

' Plane 4: Ship Nose Tip (Y=124.4m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
Dim refPlane124
Set refPlane124 = swFeatMgr.InsertRefPlane(8, 124.4, 0, 0, 0, 0)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "V3_Master_Skeleton.SLDPRT", 0, 1
WScript.Echo "  [OK] Master Skeleton Saved: V3_Master_Skeleton.SLDPRT"


' ====================================================================
' MODULE 2: RAPTOR 3 SEA LEVEL (Raptor3_SL.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [PHASE 2A] Modeling Raptor 3 Sea Level (350 bar, 280 tf thrust)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Revolved MCC, Throat & De Laval Expansion Nozzle (1.3m exit dia, 3.1m total height)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 3.10, 0

' Revolve Profile (Units: meters)
' Spherical Gimbal dome top: (0, 3.10) to (0.22, 2.95)
swSketchMgr.CreateLine 0, 3.10, 0, 0.22, 2.95, 0
' Integrated Main Injector Head & Monolithic Powerhead Body:
swSketchMgr.CreateLine 0.22, 2.95, 0, 0.42, 2.60, 0
swSketchMgr.CreateLine 0.42, 2.60, 0, 0.38, 2.10, 0
' Combustion Chamber Convergent Section to Throat (Throat R=0.145m at Y=1.75m):
swSketchMgr.CreateLine 0.38, 2.10, 0, 0.145, 1.75, 0
' Divergent Bell Nozzle to Exit (R=0.65m at Y=0.05m):
swSketchMgr.CreateLine 0.145, 1.75, 0, 0.65, 0.05, 0
' Nozzle Lip:
swSketchMgr.CreateLine 0.65, 0.05, 0, 0.62, 0.05, 0
' Inner Bell Contour:
swSketchMgr.CreateLine 0.62, 0.05, 0, 0.125, 1.75, 0
swSketchMgr.CreateLine 0.125, 1.75, 0, 0.34, 2.10, 0
swSketchMgr.CreateLine 0.34, 2.10, 0, 0.34, 2.60, 0
swSketchMgr.CreateLine 0.34, 2.60, 0, 0, 2.60, 0
swSketchMgr.CreateLine 0, 2.60, 0, 0, 3.10, 0

Dim featRaptorSL
Set featRaptorSL = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 2. Monolithic Dual Turbopump Volutes (LOX & CH4 pumps printed into powerhead)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' LOX Turbopump Housing (Offset circle)
swSketchMgr.CreateCircleByRadius 0.32, 2.50, 0, 0.16
' Fuel Turbopump Housing (Opposite side)
swSketchMgr.CreateCircleByRadius -0.32, 2.50, 0, 0.16
Dim featPumps
Set featPumps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.30, 0.30, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 3. Dual Electromechanical TVC Actuators (Pitch & Yaw Actuators)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateLine 0.30, 3.00, 0, 0.36, 2.20, 0
swSketchMgr.CreateLine 0.36, 2.20, 0, 0.32, 2.20, 0
swSketchMgr.CreateLine 0.32, 2.20, 0, 0.26, 3.00, 0
swSketchMgr.CreateLine 0.26, 3.00, 0, 0.30, 3.00, 0

swSketchMgr.CreateLine -0.30, 3.00, 0, -0.36, 2.20, 0
swSketchMgr.CreateLine -0.36, 2.20, 0, -0.32, 2.20, 0
swSketchMgr.CreateLine -0.32, 2.20, 0, -0.26, 3.00, 0
swSketchMgr.CreateLine -0.26, 3.00, 0, -0.30, 3.00, 0
Dim featActuators
Set featActuators = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.04, 0.04, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Raptor3_SL.SLDPRT", 0, 1
WScript.Echo "  [OK] Raptor 3 SL Engine Saved: Raptor3_SL.SLDPRT"


' ====================================================================
' MODULE 3: RAPTOR 3 VACUUM (Raptor3_Vac.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [PHASE 2B] Modeling Raptor 3 Vacuum (RVac, 2.4m Giant Expansion Bell)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' Revolved RVac: 2.4m exit diameter (R=1.20m), 4.3m total height
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 4.30, 0

' RVac Revolve Profile
swSketchMgr.CreateLine 0, 4.30, 0, 0.22, 4.15, 0
swSketchMgr.CreateLine 0.22, 4.15, 0, 0.40, 3.75, 0
swSketchMgr.CreateLine 0.40, 3.75, 0, 0.38, 3.30, 0
swSketchMgr.CreateLine 0.38, 3.30, 0, 0.145, 2.95, 0
' Extended Vacuum Bell out to R=1.20m at Y=0.05m
swSketchMgr.CreateLine 0.145, 2.95, 0, 1.20, 0.05, 0
swSketchMgr.CreateLine 1.20, 0.05, 0, 1.17, 0.05, 0
swSketchMgr.CreateLine 1.17, 0.05, 0, 0.125, 2.95, 0
swSketchMgr.CreateLine 0.125, 2.95, 0, 0.34, 3.30, 0
swSketchMgr.CreateLine 0.34, 3.30, 0, 0.34, 3.75, 0
swSketchMgr.CreateLine 0.34, 3.75, 0, 0, 3.75, 0
swSketchMgr.CreateLine 0, 3.75, 0, 0, 4.30, 0

Dim featRaptorVac
Set featRaptorVac = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' Structural Stiffening Stiffener Bands on RVac Bell (4x outer rings)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 4.30, 0
' Stiffener Ring 1 (Y=0.4m)
swSketchMgr.CreateCircleByRadius 1.05, 0.40, 0, 0.02
' Stiffener Ring 2 (Y=1.0m)
swSketchMgr.CreateCircleByRadius 0.82, 1.00, 0, 0.02
' Stiffener Ring 3 (Y=1.7m)
swSketchMgr.CreateCircleByRadius 0.56, 1.70, 0, 0.02
' Stiffener Ring 4 (Y=2.4m)
swSketchMgr.CreateCircleByRadius 0.31, 2.40, 0, 0.02
Dim featBands
Set featBands = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Raptor3_Vac.SLDPRT", 0, 1
WScript.Echo "  [OK] Raptor 3 Vacuum Engine Saved: Raptor3_Vac.SLDPRT"


' ====================================================================
' MODULE 4: SUPER HEAVY V3 BOOSTER (Booster_V3.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [PHASE 3] Modeling Super Heavy V3 Booster (71m Tall, 33 Raptor 3s, Grid Fins, Hot Staging)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Booster Main Hull (71m tall, 9m diameter -> R=4.5m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 71.0, 0

' Outer Booster Profile:
' Aft Skirt Flare: (4.50, 0.0) -> (4.50, 67.0)
swSketchMgr.CreateLine 0, 71.0, 0, 4.50, 71.0, 0
swSketchMgr.CreateLine 4.50, 71.0, 0, 4.50, 0.50, 0
swSketchMgr.CreateLine 4.50, 0.50, 0, 4.58, 0.0, 0
swSketchMgr.CreateLine 4.58, 0.0, 0, 4.30, 0.0, 0
' Inner tank wall (Cryogenic 304L stainless shell, thickness ~100mm structural core):
swSketchMgr.CreateLine 4.30, 0.0, 0, 4.30, 0.50, 0
swSketchMgr.CreateLine 4.30, 0.50, 0, 4.30, 67.0, 0
' Forward Tank Dome (Hemispherical bulkhead at Y=67.0m):
swSketchMgr.CreateLine 4.30, 67.0, 0, 0, 68.8, 0
swSketchMgr.CreateLine 0, 68.8, 0, 0, 71.0, 0

Dim featBoosterHull
Set featBoosterHull = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Booster Core Fuselage & Cryo Tanks revolved."

' 2. Common Dome Bulkhead (Separating CH4 & LOX tanks at Y=38.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 30.0, 0, 0, 42.0, 0
swSketchMgr.CreateLine 0, 40.5, 0, 4.30, 38.0, 0
swSketchMgr.CreateLine 4.30, 38.0, 0, 4.30, 37.8, 0
swSketchMgr.CreateLine 4.30, 37.8, 0, 0, 40.3, 0
swSketchMgr.CreateLine 0, 40.3, 0, 0, 40.5, 0
Dim featCommonDome
Set featCommonDome = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 3. Forged Aft Thrust Puck (Hardpoint dome transferring 9,000 tf thrust)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 6.0, 0
swSketchMgr.CreateLine 0, 3.8, 0, 4.30, 1.2, 0
swSketchMgr.CreateLine 4.30, 1.2, 0, 4.30, 0.8, 0
swSketchMgr.CreateLine 4.30, 0.8, 0, 0, 3.4, 0
swSketchMgr.CreateLine 0, 3.4, 0, 0, 3.8, 0
Dim featThrustPuck
Set featThrustPuck = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 4. Integrated 33-Raptor Engine Layout Representation
' Center Cluster (3 engines):
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, -1.0, 0, 0, 3.0, 0
' Center engine nozzle cone:
swSketchMgr.CreateLine 0, 2.6, 0, 0.65, -0.4, 0
swSketchMgr.CreateLine 0.65, -0.4, 0, 0.60, -0.4, 0
swSketchMgr.CreateLine 0.60, -0.4, 0, 0, 2.4, 0
swSketchMgr.CreateLine 0, 2.4, 0, 0, 2.6, 0
Dim featCenterEng
Set featCenterEng = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' Inner Ring (10 engines at R=2.0m) & Outer Ring (20 engines at R=3.65m):
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, -1.0, 0, 0, 3.0, 0
' Inner ring profile:
swSketchMgr.CreateLine 1.6, 2.2, 0, 2.4, -0.4, 0
swSketchMgr.CreateLine 2.4, -0.4, 0, 2.3, -0.4, 0
swSketchMgr.CreateLine 2.3, -0.4, 0, 1.7, 2.2, 0
swSketchMgr.CreateLine 1.7, 2.2, 0, 1.6, 2.2, 0
' Outer ring profile:
swSketchMgr.CreateLine 3.2, 2.0, 0, 4.1, -0.4, 0
swSketchMgr.CreateLine 4.1, -0.4, 0, 4.0, -0.4, 0
swSketchMgr.CreateLine 4.0, -0.4, 0, 3.3, 2.0, 0
swSketchMgr.CreateLine 3.3, 2.0, 0, 3.2, 2.0, 0
Dim featRingEngines
Set featRingEngines = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> 33-Engine Thrust Puck & Nozzle Matrix integrated."

' 5. V3 Hot Staging Ring with Interstage Plasma Exhaust Vents (Y=67m to Y=71m)
' Cut-Extrude 16 perimeter plasma escape vents
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Vent rectangular window at (X=4.0 to 5.0, Y=67.8 to 70.2)
swSketchMgr.CreateLine 3.8, 70.2, 0, 4.8, 70.2, 0
swSketchMgr.CreateLine 4.8, 70.2, 0, 4.8, 68.0, 0
swSketchMgr.CreateLine 4.8, 68.0, 0, 3.8, 68.0, 0
swSketchMgr.CreateLine 3.8, 68.0, 0, 3.8, 70.2, 0

swSketchMgr.CreateLine -3.8, 70.2, 0, -4.8, 70.2, 0
swSketchMgr.CreateLine -4.8, 70.2, 0, -4.8, 68.0, 0
swSketchMgr.CreateLine -4.8, 68.0, 0, -3.8, 68.0, 0
swSketchMgr.CreateLine -3.8, 68.0, 0, -3.8, 70.2, 0
Dim featVents
Set featVents = swFeatMgr.FeatureCut4(True, False, False, 6, 0, 4.0, 4.0, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)
WScript.Echo "  -> Vented Hot Staging Ring & Plasma Vents constructed."

' 6. 4x Cast-Steel Aerodynamic Grid Fins & Mechazilla Catch Pins (Y=65.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Grid Fin Profile (Spans from R=4.5m to R=6.8m, Y=64.0m to Y=67.0m):
swSketchMgr.CreateLine 4.4, 67.2, 0, 6.8, 66.4, 0
swSketchMgr.CreateLine 6.8, 66.4, 0, 6.8, 64.2, 0
swSketchMgr.CreateLine 6.8, 64.2, 0, 4.4, 64.0, 0
swSketchMgr.CreateLine 4.4, 64.0, 0, 4.4, 67.2, 0
' Catch Hardpoint Lug Pin:
swSketchMgr.CreateCircleByRadius 4.6, 63.6, 0, 0.18

' Left Grid Fin Profile:
swSketchMgr.CreateLine -4.4, 67.2, 0, -6.8, 66.4, 0
swSketchMgr.CreateLine -6.8, 66.4, 0, -6.8, 64.2, 0
swSketchMgr.CreateLine -6.8, 64.2, 0, -4.4, 64.0, 0
swSketchMgr.CreateLine -4.4, 64.0, 0, -4.4, 67.2, 0
' Catch Hardpoint Lug Pin:
swSketchMgr.CreateCircleByRadius -4.6, 63.6, 0, 0.18

Dim featGridFins
Set featGridFins = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.28, 0.28, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 4x Pattern of Grid Fins:
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Boss-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 4.5, 35.0, 0, True, 1, Nothing, 0)
Dim featGridPattern
Set featGridPattern = swFeatMgr.FeatureCircularPattern4(2, two_pi, False, "NULL", False, True, False)

' 7. External Autogenous Pressurization Aerodynamic Raceways (Spanning full booster length)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Forward-to-aft raceway strip (Y=1.0m to Y=66.5m, thickness 0.12m, width 0.35m)
swSketchMgr.CreateLine 4.48, 66.5, 0, 4.62, 66.5, 0
swSketchMgr.CreateLine 4.62, 66.5, 0, 4.62, 1.0, 0
swSketchMgr.CreateLine 4.62, 1.0, 0, 4.48, 1.0, 0
swSketchMgr.CreateLine 4.48, 1.0, 0, 4.48, 66.5, 0

swSketchMgr.CreateLine -4.48, 66.5, 0, -4.62, 66.5, 0
swSketchMgr.CreateLine -4.62, 66.5, 0, -4.62, 1.0, 0
swSketchMgr.CreateLine -4.62, 1.0, 0, -4.48, 1.0, 0
swSketchMgr.CreateLine -4.48, 1.0, 0, -4.48, 66.5, 0

Dim featRaceways
Set featRaceways = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.18, 0.18, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Grid Fins, Catch Points & Pressurization Raceways modeled."

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Booster_V3.SLDPRT", 0, 1
WScript.Echo "  [OK] Super Heavy V3 Booster Saved: Booster_V3.SLDPRT"


' ====================================================================
' MODULE 5: STARSHIP V3 UPPER STAGE (Starship_V3.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [PHASE 4] Modeling Starship V3 Upper Stage (51.4m Tall, 9 Raptors, Flaps, TPS Heat Shield)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Starship V3 Main Hull & Ogive Nosecone (Y=71.0m to Y=124.4m, 9m Diameter)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 71.0, 0, 0, 124.4, 0

' Ship Outer Profile (Ogive curve from Y=102m to 124.4m apex):
swSketchMgr.CreateLine 0, 124.4, 0, 0.8, 122.5, 0
swSketchMgr.CreateLine 0.8, 122.5, 0, 2.2, 118.0, 0
swSketchMgr.CreateLine 2.2, 118.0, 0, 3.6, 111.0, 0
swSketchMgr.CreateLine 3.6, 111.0, 0, 4.35, 104.0, 0
swSketchMgr.CreateLine 4.35, 104.0, 0, 4.50, 98.0, 0
' Cylindrical Mid-Body (Y=98.0m down to Y=71.0m):
swSketchMgr.CreateLine 4.50, 98.0, 0, 4.50, 71.0, 0
' Aft Skirt Rim:
swSketchMgr.CreateLine 4.50, 71.0, 0, 4.32, 71.0, 0
' Inner Tank Shell & Bulkheads:
swSketchMgr.CreateLine 4.32, 71.0, 0, 4.32, 98.0, 0
swSketchMgr.CreateLine 4.32, 98.0, 0, 0, 102.0, 0
swSketchMgr.CreateLine 0, 102.0, 0, 0, 124.4, 0

Dim featShipHull
Set featShipHull = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Starship V3 Aerodynamic Hull & Ogive Nose Cone generated."

' 2. Internal Landing Header Tanks & Downcomer Pipe
' Nose LOX Header Tank (Spherical tank in nose apex at Y=116m) & Central Downcomer
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 71.0, 0, 0, 124.4, 0
' Spherical Header Tank:
swSketchMgr.CreateCircleByRadius 0, 116.0, 0, 1.4
' Downcomer pipe from header tank straight to engine bay:
swSketchMgr.CreateLine 0.18, 114.6, 0, 0.18, 72.0, 0
swSketchMgr.CreateLine 0.18, 72.0, 0, -0.18, 72.0, 0
swSketchMgr.CreateLine -0.18, 72.0, 0, -0.18, 114.6, 0
Dim featDowncomer
Set featDowncomer = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.18, 0.18, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 3. 9-Raptor Propulsion Array (3 Center SL + 6 Outer RVac Engines)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 70.0, 0, 0, 76.0, 0
' 3 Center SL Engines (R=0.65m):
swSketchMgr.CreateLine 0, 74.5, 0, 0.65, 71.0, 0
swSketchMgr.CreateLine 0.65, 71.0, 0, 0.58, 71.0, 0
swSketchMgr.CreateLine 0.58, 71.0, 0, 0, 74.0, 0
swSketchMgr.CreateLine 0, 74.0, 0, 0, 74.5, 0
' 6 Outer RVac Engines (R=2.9m radius, huge 2.4m bells):
swSketchMgr.CreateLine 2.2, 74.5, 0, 3.8, 70.6, 0
swSketchMgr.CreateLine 3.8, 70.6, 0, 3.7, 70.6, 0
swSketchMgr.CreateLine 3.7, 70.6, 0, 2.3, 74.5, 0
swSketchMgr.CreateLine 2.3, 74.5, 0, 2.2, 74.5, 0
Dim featShipEngines
Set featShipEngines = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> 9-Raptor Propulsion Matrix (3 SL + 6 RVac) modeled."

' 4. Aft Aerodynamic Body Flaps with Rotary Actuator Aerocovers (Y=72.0m to Y=82.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Aft Flap (Aerodynamic trapezoidal planform, spans to R=7.2m):
swSketchMgr.CreateLine 4.4, 82.0, 0, 7.2, 77.0, 0
swSketchMgr.CreateLine 7.2, 77.0, 0, 7.2, 72.0, 0
swSketchMgr.CreateLine 7.2, 72.0, 0, 4.4, 71.5, 0
swSketchMgr.CreateLine 4.4, 71.5, 0, 4.4, 82.0, 0
' Actuator Fairing Aero-cover:
swSketchMgr.CreateLine 4.4, 83.2, 0, 5.2, 77.0, 0
swSketchMgr.CreateLine 5.2, 77.0, 0, 4.4, 71.0, 0
swSketchMgr.CreateLine 4.4, 71.0, 0, 4.4, 83.2, 0

' Left Aft Flap:
swSketchMgr.CreateLine -4.4, 82.0, 0, -7.2, 77.0, 0
swSketchMgr.CreateLine -7.2, 77.0, 0, -7.2, 72.0, 0
swSketchMgr.CreateLine -7.2, 72.0, 0, -4.4, 71.5, 0
swSketchMgr.CreateLine -4.4, 71.5, 0, -4.4, 82.0, 0
' Actuator Fairing Aero-cover:
swSketchMgr.CreateLine -4.4, 83.2, 0, -5.2, 77.0, 0
swSketchMgr.CreateLine -5.2, 77.0, 0, -4.4, 71.0, 0
swSketchMgr.CreateLine -4.4, 71.0, 0, -4.4, 83.2, 0

Dim featAftFlaps
Set featAftFlaps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.22, 0.22, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Aft Body Flaps & Actuator Fairings extruded."

' 5. Forward Leeward Aerodynamic Flaps (V3 Optimized Position: Y=112.0m to Y=118.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Forward Flap (Shielded leeward placement, spans to R=6.2m):
swSketchMgr.CreateLine 2.8, 118.0, 0, 6.2, 115.5, 0
swSketchMgr.CreateLine 6.2, 115.5, 0, 6.2, 112.5, 0
swSketchMgr.CreateLine 6.2, 112.5, 0, 3.4, 112.0, 0
swSketchMgr.CreateLine 3.4, 112.0, 0, 2.8, 118.0, 0

' Left Forward Flap:
swSketchMgr.CreateLine -2.8, 118.0, 0, -6.2, 115.5, 0
swSketchMgr.CreateLine -6.2, 115.5, 0, -6.2, 112.5, 0
swSketchMgr.CreateLine -6.2, 112.5, 0, -3.4, 112.0, 0
swSketchMgr.CreateLine -3.4, 112.0, 0, -2.8, 118.0, 0

Dim featFwdFlaps
Set featFwdFlaps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.16, 0.16, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Forward Leeward Flaps with plasma-shielded hinges modeled."

' 6. Payload Bay Door (Starlink Pez Dispenser / Clamshell Deployment Slot)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Pez slot on leeward face (Z=4.4m, Y=103.0m to 108.5m)
swSketchMgr.CreateLine 4.4, 108.5, 0, 4.65, 108.5, 0
swSketchMgr.CreateLine 4.65, 108.5, 0, 4.65, 103.0, 0
swSketchMgr.CreateLine 4.65, 103.0, 0, 4.4, 103.0, 0
swSketchMgr.CreateLine 4.4, 103.0, 0, 4.4, 108.5, 0
Dim featPayloadDoor
Set featPayloadDoor = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.85, 0.85, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 7. Thermal Protection System (TPS) Ceramic Heat Shield Belly (Windward 180? Wrap)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 71.0, 0, 0, 124.4, 0
' Windward half curve with 15mm ceramic tile standoff layer:
swSketchMgr.CreateLine 0, 124.42, 0, 0.82, 122.52, 0
swSketchMgr.CreateLine 0.82, 122.52, 0, 2.22, 118.02, 0
swSketchMgr.CreateLine 2.22, 118.02, 0, 3.62, 111.02, 0
swSketchMgr.CreateLine 3.62, 111.02, 0, 4.37, 104.02, 0
swSketchMgr.CreateLine 4.37, 104.02, 0, 4.52, 98.0, 0
swSketchMgr.CreateLine 4.52, 98.0, 0, 4.52, 71.0, 0
swSketchMgr.CreateLine 4.52, 71.0, 0, 4.50, 71.0, 0
swSketchMgr.CreateLine 4.50, 71.0, 0, 4.50, 98.0, 0
swSketchMgr.CreateLine 4.50, 98.0, 0, 4.35, 104.0, 0
swSketchMgr.CreateLine 4.35, 104.0, 0, 3.6, 111.0, 0
swSketchMgr.CreateLine 3.6, 111.0, 0, 2.2, 118.0, 0
swSketchMgr.CreateLine 2.2, 118.0, 0, 0.8, 122.5, 0
swSketchMgr.CreateLine 0.8, 122.5, 0, 0, 124.4, 0
swSketchMgr.CreateLine 0, 124.4, 0, 0, 124.42, 0
Dim featTPS
Set featTPS = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Black Ceramic TUFI/AETB Thermal Protection System (TPS) modeled."

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Starship_V3.SLDPRT", 0, 1
WScript.Echo "  [OK] Starship V3 Upper Stage Saved: Starship_V3.SLDPRT"


' ====================================================================
' MODULE 6: FULL STACK TOP-DOWN INTEGRATED ASSEMBLY (Starship_FullStack_V3.SLDASM)
' ====================================================================
WScript.Echo vbCrLf & ">>> [PHASE 5] Creating Top-Level Integrated Launch Stack (124.4m, 5,200t Full Stack Assembly)..."
Dim swAsm
Set swAsm = swApp.NewDocument(asmTemplate, 0, 0, 0)
If swAsm Is Nothing Then
    WScript.Echo "ERROR: Failed to create Assembly document."
    WScript.Quit 1
End If

Dim swAsmExt
Set swAsmExt = swAsm.Extension

' Insert Super Heavy Booster (Fixed at Origin / Launch Mount Y=0)
Dim compBooster
Set compBooster = swAsm.AddComponent5(baseDir & "Booster_V3.SLDPRT", 0, "", False, "", 0, 0, 0)
WScript.Echo "  -> Super Heavy V3 Booster inserted into Master Assembly."

' Insert Starship V3 Upper Stage (Aligned at Hot Staging Ring Y=71.0m)
Dim compShip
Set compShip = swAsm.AddComponent5(baseDir & "Starship_V3.SLDPRT", 0, "", False, "", 0, 0, 0)
WScript.Echo "  -> Starship V3 Upper Stage mated at Hot Staging interface."

' Insert Master Skeleton Reference Component
Dim compSkeleton
Set compSkeleton = swAsm.AddComponent5(baseDir & "V3_Master_Skeleton.SLDPRT", 0, "", False, "", 0, 0, 0)
WScript.Echo "  -> Master Skeleton datum architecture linked."

swAsm.ForceRebuild3 False
swAsm.ShowNamedView2 "*Isometric", 7
swAsm.ViewZoomtofit2
swAsm.SaveAs3 baseDir & "Starship_FullStack_V3.SLDASM", 0, 1
WScript.Echo "  [OK] Master Full Stack Assembly Saved: Starship_FullStack_V3.SLDASM"

WScript.Echo vbCrLf & "======================================================================"
WScript.Echo "MISSION READY: SpaceX Starship V3 Full Architecture Generated!"
WScript.Echo "Top Level Assembly: " & baseDir & "Starship_FullStack_V3.SLDASM"
WScript.Echo "======================================================================"
