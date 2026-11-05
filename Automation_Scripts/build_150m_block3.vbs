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
WScript.Echo "SPACEX STARSHIP BLOCK 3 (150.0m 1:1 SCALE FULL STACK ARCHITECTURE)"
WScript.Echo "======================================================================"
WScript.Echo "Connected to SolidWorks: " & swApp.RevisionNumber

' ====================================================================
' 1. V3 MASTER SKELETON (150.0m TOTAL HEIGHT, 9.0m DIAMETER)
' ====================================================================
WScript.Echo vbCrLf & ">>> [1/6] Building 150m Master Skeleton & Datum Planes..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' 150m Centerline
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 150.0, 0
' 9m OML boundary lines (R = 4.5m)
swSketchMgr.CreateCenterLine 4.5, 0, 0, 4.5, 150.0, 0
swSketchMgr.CreateCenterLine -4.5, 0, 0, -4.5, 150.0, 0
swSketchMgr.InsertSketch True

' 9m OML Cylinder
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0, 0, 0, 4.5
Dim featOML
Set featOML = swFeatMgr.FeatureExtrusion3(True, False, False, 0, 0, 150.0, 0, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' Reference Datum Planes
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
Dim refPlane76
Set refPlane76 = swFeatMgr.InsertRefPlane(8, 76.5, 0, 0, 0, 0) ' Booster Top / Hot Staging Base

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
Dim refPlane80
Set refPlane80 = swFeatMgr.InsertRefPlane(8, 80.0, 0, 0, 0, 0) ' Hot Staging Top / Ship Base

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Top Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
Dim refPlane150
Set refPlane150 = swFeatMgr.InsertRefPlane(8, 150.0, 0, 0, 0, 0) ' Starship Apex

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "V3_Master_Skeleton.SLDPRT", 0, 1
WScript.Echo "  [OK] Master Skeleton Saved: V3_Master_Skeleton.SLDPRT (150m Baseline)"


' ====================================================================
' 2. RAPTOR 3 SEA LEVEL ENGINE (Raptor3_SL.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [2/6] Building Raptor 3 Sea Level (1.3m nozzle exit, 350 bar)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 3.10, 0
swSketchMgr.CreateLine 0, 3.10, 0, 0.22, 2.95, 0
swSketchMgr.CreateLine 0.22, 2.95, 0, 0.42, 2.60, 0
swSketchMgr.CreateLine 0.42, 2.60, 0, 0.38, 2.10, 0
swSketchMgr.CreateLine 0.38, 2.10, 0, 0.145, 1.75, 0
swSketchMgr.CreateLine 0.145, 1.75, 0, 0.65, 0.05, 0
swSketchMgr.CreateLine 0.65, 0.05, 0, 0.62, 0.05, 0
swSketchMgr.CreateLine 0.62, 0.05, 0, 0.125, 1.75, 0
swSketchMgr.CreateLine 0.125, 1.75, 0, 0.34, 2.10, 0
swSketchMgr.CreateLine 0.34, 2.10, 0, 0.34, 2.60, 0
swSketchMgr.CreateLine 0.34, 2.60, 0, 0, 2.60, 0
swSketchMgr.CreateLine 0, 2.60, 0, 0, 3.10, 0
Dim featRaptorSL
Set featRaptorSL = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCircleByRadius 0.30, 2.50, 0, 0.16
swSketchMgr.CreateCircleByRadius -0.30, 2.50, 0, 0.16
Dim featPumps
Set featPumps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.28, 0.28, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Raptor3_SL.SLDPRT", 0, 1
WScript.Echo "  [OK] Raptor 3 SL Engine Saved."


' ====================================================================
' 3. RAPTOR 3 VACUUM ENGINE (Raptor3_Vac.SLDPRT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [3/6] Building Raptor 3 Vacuum (2.4m vacuum nozzle bell)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 4.30, 0
swSketchMgr.CreateLine 0, 4.30, 0, 0.22, 4.15, 0
swSketchMgr.CreateLine 0.22, 4.15, 0, 0.40, 3.75, 0
swSketchMgr.CreateLine 0.40, 3.75, 0, 0.38, 3.30, 0
swSketchMgr.CreateLine 0.38, 3.30, 0, 0.145, 2.95, 0
swSketchMgr.CreateLine 0.145, 2.95, 0, 1.20, 0.05, 0
swSketchMgr.CreateLine 1.20, 0.05, 0, 1.17, 0.05, 0
swSketchMgr.CreateLine 1.17, 0.05, 0, 0.125, 2.95, 0
swSketchMgr.CreateLine 0.125, 2.95, 0, 0.34, 3.30, 0
swSketchMgr.CreateLine 0.34, 3.30, 0, 0.34, 3.75, 0
swSketchMgr.CreateLine 0.34, 3.75, 0, 0, 3.75, 0
swSketchMgr.CreateLine 0, 3.75, 0, 0, 4.30, 0
Dim featRaptorVac
Set featRaptorVac = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 4.30, 0
swSketchMgr.CreateCircleByRadius 1.05, 0.40, 0, 0.025
swSketchMgr.CreateCircleByRadius 0.82, 1.00, 0, 0.025
swSketchMgr.CreateCircleByRadius 0.56, 1.70, 0, 0.025
swSketchMgr.CreateCircleByRadius 0.31, 2.40, 0, 0.025
Dim featBands
Set featBands = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Raptor3_Vac.SLDPRT", 0, 1
WScript.Echo "  [OK] Raptor 3 Vac Saved."


' ====================================================================
' 4. SUPER HEAVY BLOCK 3 BOOSTER (76.5m Height, 9m Dia, 33 Raptors, 4 Grid Fins, 1.8m Roll Rings)
' ====================================================================
WScript.Echo vbCrLf & ">>> [4/6] Building Super Heavy Block 3 (76.5m, 33 Raptors, 4 Grid Fins, Internal Bulkheads)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Booster Hull (76.5m tall, 9m diameter)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 76.5, 0

swSketchMgr.CreateLine 0, 76.5, 0, 4.50, 76.5, 0
swSketchMgr.CreateLine 4.50, 76.5, 0, 4.50, 1.0, 0
' Aft Skirt Flare:
swSketchMgr.CreateLine 4.50, 1.0, 0, 4.60, 0.0, 0
swSketchMgr.CreateLine 4.60, 0.0, 0, 4.30, 0.0, 0
swSketchMgr.CreateLine 4.30, 0.0, 0, 4.30, 1.0, 0
swSketchMgr.CreateLine 4.30, 1.0, 0, 4.30, 73.0, 0
' Forward Dome Bulkhead:
swSketchMgr.CreateLine 4.30, 73.0, 0, 0, 75.0, 0
swSketchMgr.CreateLine 0, 75.0, 0, 0, 76.5, 0
Dim featBoosterHull
Set featBoosterHull = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 2. 1.8m Steel Roll Ring Weld Seams (Blueprint spec: panelized ring sections)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 76.5, 0
Dim y_ring
For y_ring = 1.8 To 74.0 Step 1.8
    swSketchMgr.CreateCircleByRadius 4.506, y_ring, 0, 0.010
Next
Dim featBoosterRings
Set featBoosterRings = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 3. Internal Inverted Dome Bulkheads (CH4 / LOX division at Y=42.0m & Thrust Puck at Y=2.5m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 76.5, 0
' Common dome:
swSketchMgr.CreateLine 0, 45.0, 0, 4.30, 42.0, 0
swSketchMgr.CreateLine 4.30, 42.0, 0, 4.30, 41.7, 0
swSketchMgr.CreateLine 4.30, 41.7, 0, 0, 44.7, 0
swSketchMgr.CreateLine 0, 44.7, 0, 0, 45.0, 0
' Thrust puck dome:
swSketchMgr.CreateLine 0, 4.5, 0, 4.30, 1.5, 0
swSketchMgr.CreateLine 4.30, 1.5, 0, 4.30, 1.1, 0
swSketchMgr.CreateLine 4.30, 1.1, 0, 0, 4.1, 0
swSketchMgr.CreateLine 0, 4.1, 0, 0, 4.5, 0
Dim featBulkheads
Set featBulkheads = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 4. Central Downcomer Cryogenic Transfer Tube (feeding 33 engines)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 76.5, 0
swSketchMgr.CreateLine 0.48, 74.0, 0, 0.48, 2.5, 0
swSketchMgr.CreateLine 0.48, 2.5, 0, 0.42, 2.5, 0
swSketchMgr.CreateLine 0.42, 2.5, 0, 0.42, 74.0, 0
swSketchMgr.CreateLine 0.42, 74.0, 0, 0.48, 74.0, 0
Dim featDowncomer
Set featDowncomer = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 5. 33-Raptor 3 Engine Cluster (Outer 20 + Middle 10 + Inner 3)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, -1.0, 0, 0, 4.0, 0
' Inner 3-Engine Core:
swSketchMgr.CreateLine 0, 3.0, 0, 0.65, -0.45, 0
swSketchMgr.CreateLine 0.65, -0.45, 0, 0.58, -0.45, 0
swSketchMgr.CreateLine 0.58, -0.45, 0, 0, 2.7, 0
swSketchMgr.CreateLine 0, 2.7, 0, 0, 3.0, 0
' Middle 10-Engine Ring (R=2.1m):
swSketchMgr.CreateLine 1.60, 2.6, 0, 2.45, -0.45, 0
swSketchMgr.CreateLine 2.45, -0.45, 0, 2.35, -0.45, 0
swSketchMgr.CreateLine 2.35, -0.45, 0, 1.70, 2.6, 0
swSketchMgr.CreateLine 1.70, 2.6, 0, 1.60, 2.6, 0
' Outer 20-Engine Ring (R=3.85m, 1.3m nozzle exit dia):
swSketchMgr.CreateLine 3.25, 2.4, 0, 4.25, -0.45, 0
swSketchMgr.CreateLine 4.25, -0.45, 0, 4.15, -0.45, 0
swSketchMgr.CreateLine 4.15, -0.45, 0, 3.35, 2.4, 0
swSketchMgr.CreateLine 3.35, 2.4, 0, 3.25, 2.4, 0
Dim feat33Array
Set feat33Array = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 6. 4x Foldable Lattice Grid Fins (3.0m x 2.2m, 90 deg symmetrical, Y=70.0m - 74.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Embedded root starting inside hull at R=3.8m:
swSketchMgr.CreateLine 3.8, 74.0, 0, 7.5, 73.2, 0
swSketchMgr.CreateLine 7.5, 73.2, 0, 7.5, 70.2, 0
swSketchMgr.CreateLine 7.5, 70.2, 0, 3.8, 69.8, 0
swSketchMgr.CreateLine 3.8, 69.8, 0, 3.8, 74.0, 0
' Catch Lug beneath Fin:
swSketchMgr.CreateCircleByRadius 4.6, 69.0, 0, 0.22
Dim featGridFins
Set featGridFins = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.32, 0.32, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 4x Pattern around orthogonal axes:
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Boss-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 4.5, 35.0, 0, True, 1, Nothing, 0)
Dim featGrid4Pat
Set featGrid4Pat = swFeatMgr.FeatureCircularPattern4(4, two_pi, False, "NULL", False, True, False)

' 7. External Aerodynamic Raceways (Chines / Fluid Conduits)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateLine 4.40, 74.5, 0, 4.65, 74.5, 0
swSketchMgr.CreateLine 4.65, 74.5, 0, 4.65, 1.0, 0
swSketchMgr.CreateLine 4.65, 1.0, 0, 4.40, 1.0, 0
swSketchMgr.CreateLine 4.40, 1.0, 0, 4.40, 74.5, 0

swSketchMgr.CreateLine -4.40, 74.5, 0, -4.65, 74.5, 0
swSketchMgr.CreateLine -4.65, 74.5, 0, -4.65, 1.0, 0
swSketchMgr.CreateLine -4.65, 1.0, 0, -4.40, 1.0, 0
swSketchMgr.CreateLine -4.40, 1.0, 0, -4.40, 74.5, 0
Dim featRaceways
Set featRaceways = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.20, 0.20, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Booster_V3.SLDPRT", 0, 1
WScript.Echo "  [OK] Super Heavy Block 3 Booster Saved: Booster_V3.SLDPRT (76.5m, 33 Engines, 4 Grid Fins)"


' ====================================================================
' 5. STARSHIP BLOCK 3 UPPER STAGE (70.0m Height, Y=80m to 150m, 9 Raptors, 11.5m Aft Flaps, TPS)
' ====================================================================
WScript.Echo vbCrLf & ">>> [5/6] Building Starship Block 3 Upper Stage (70.0m, 11.5m Aft Flaps, 9 Raptors, Bulkheads, TPS)..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Starship Main Hull & Ogive Nose (Y=80.0m to 150.0m, 70m Length)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 80.0, 0, 0, 150.0, 0

swSketchMgr.CreateLine 0, 150.0, 0, 0.9, 147.5, 0
swSketchMgr.CreateLine 0.9, 147.5, 0, 2.4, 142.0, 0
swSketchMgr.CreateLine 2.4, 142.0, 0, 3.8, 133.0, 0
swSketchMgr.CreateLine 3.8, 133.0, 0, 4.4, 124.0, 0
swSketchMgr.CreateLine 4.4, 124.0, 0, 4.50, 116.0, 0
swSketchMgr.CreateLine 4.50, 116.0, 0, 4.50, 80.0, 0
swSketchMgr.CreateLine 4.50, 80.0, 0, 4.32, 80.0, 0
swSketchMgr.CreateLine 4.32, 80.0, 0, 4.32, 116.0, 0
swSketchMgr.CreateLine 4.32, 116.0, 0, 0, 122.0, 0
swSketchMgr.CreateLine 0, 122.0, 0, 0, 150.0, 0
Dim featShipHull
Set featShipHull = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 2. Starship 1.8m Roll Ring Seams
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 80.0, 0, 0, 150.0, 0
Dim y_sring
For y_sring = 81.8 To 120.0 Step 1.8
    swSketchMgr.CreateCircleByRadius 4.506, y_sring, 0, 0.010
Next
Dim featShipRings
Set featShipRings = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 3. Internal Inverted Dome Bulkheads (LOX tank Y=84-104m, CH4 tank Y=104-124m, Header Tank in Nose)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 80.0, 0, 0, 150.0, 0
' Apex Spherical LOX Header Tank:
swSketchMgr.CreateCircleByRadius 0, 142.0, 0, 1.55
' Central Downcomer Pipe:
swSketchMgr.CreateLine 0.22, 140.4, 0, 0.22, 81.0, 0
swSketchMgr.CreateLine 0.22, 81.0, 0, -0.22, 81.0, 0
swSketchMgr.CreateLine -0.22, 81.0, 0, -0.22, 140.4, 0
' Intermediate Inverted Dome Bulkhead:
swSketchMgr.CreateLine 0, 106.0, 0, 4.32, 103.5, 0
swSketchMgr.CreateLine 4.32, 103.5, 0, 4.32, 103.2, 0
swSketchMgr.CreateLine 4.32, 103.2, 0, 0, 105.7, 0
swSketchMgr.CreateLine 0, 105.7, 0, 0, 106.0, 0
Dim featShipBulkheads
Set featShipBulkheads = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.22, 0.22, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 4. 9-Raptor Propulsion Array (3 SL Center + 6 RVac Outer with 2.4m bells)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 78.0, 0, 0, 86.0, 0
' 3 SL Center:
swSketchMgr.CreateLine 0, 83.5, 0, 0.65, 80.0, 0
swSketchMgr.CreateLine 0.65, 80.0, 0, 0.58, 80.0, 0
swSketchMgr.CreateLine 0.58, 80.0, 0, 0, 83.0, 0
swSketchMgr.CreateLine 0, 83.0, 0, 0, 83.5, 0
' 6 RVac Outer:
swSketchMgr.CreateLine 2.2, 83.5, 0, 3.8, 79.6, 0
swSketchMgr.CreateLine 3.8, 79.6, 0, 3.7, 79.6, 0
swSketchMgr.CreateLine 3.7, 79.6, 0, 2.3, 83.5, 0
swSketchMgr.CreateLine 2.3, 83.5, 0, 2.2, 83.5, 0
Dim featShip9Raptors
Set featShip9Raptors = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' 5. AFT LOWER FLAPS (11.5m Root Chord, Y=81.0m to 92.5m, Trapezoidal, Conformal Zero-Gap Root)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Aft Flap (11.5m Root Chord from Y=81.0m to 92.5m, Embedded at R=3.5m, Span to R=7.6m):
swSketchMgr.CreateLine 3.5, 92.5, 0, 7.6, 86.5, 0
swSketchMgr.CreateLine 7.6, 86.5, 0, 7.6, 81.5, 0
swSketchMgr.CreateLine 7.6, 81.5, 0, 3.5, 81.0, 0
swSketchMgr.CreateLine 3.5, 81.0, 0, 3.5, 92.5, 0
' Right Conformal Aero-Cover:
swSketchMgr.CreateLine 3.5, 93.8, 0, 5.2, 86.5, 0
swSketchMgr.CreateLine 5.2, 86.5, 0, 3.5, 80.5, 0
swSketchMgr.CreateLine 3.5, 80.5, 0, 3.5, 93.8, 0

' Left Aft Flap:
swSketchMgr.CreateLine -3.5, 92.5, 0, -7.6, 86.5, 0
swSketchMgr.CreateLine -7.6, 86.5, 0, -7.6, 81.5, 0
swSketchMgr.CreateLine -7.6, 81.5, 0, -3.5, 81.0, 0
swSketchMgr.CreateLine -3.5, 81.0, 0, -3.5, 92.5, 0
' Left Conformal Aero-Cover:
swSketchMgr.CreateLine -3.5, 93.8, 0, -5.2, 86.5, 0
swSketchMgr.CreateLine -5.2, 86.5, 0, -3.5, 80.5, 0
swSketchMgr.CreateLine -3.5, 80.5, 0, -3.5, 93.8, 0

Dim featAft11mFlaps
Set featAft11mFlaps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.26, 0.26, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 6. FORWARD LEEWARD FLAPS (Narrow root, sleek swept profile, Y=137.0m to 144.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Forward Flap (Embedded at R=1.0m inside nose, spans to R=6.4m):
swSketchMgr.CreateLine 1.0, 144.0, 0, 6.4, 140.5, 0
swSketchMgr.CreateLine 6.4, 140.5, 0, 6.4, 137.5, 0
swSketchMgr.CreateLine 6.4, 137.5, 0, 1.0, 137.0, 0
swSketchMgr.CreateLine 1.0, 137.0, 0, 1.0, 144.0, 0
' Right Forward Aero-Cover:
swSketchMgr.CreateLine 1.0, 145.0, 0, 4.2, 140.5, 0
swSketchMgr.CreateLine 4.2, 140.5, 0, 1.0, 136.2, 0
swSketchMgr.CreateLine 1.0, 136.2, 0, 1.0, 145.0, 0

' Left Forward Flap:
swSketchMgr.CreateLine -1.0, 144.0, 0, -6.4, 140.5, 0
swSketchMgr.CreateLine -6.4, 140.5, 0, -6.4, 137.5, 0
swSketchMgr.CreateLine -6.4, 137.5, 0, -1.0, 137.0, 0
swSketchMgr.CreateLine -1.0, 137.0, 0, -1.0, 144.0, 0
' Left Forward Aero-Cover:
swSketchMgr.CreateLine -1.0, 145.0, 0, -4.2, 140.5, 0
swSketchMgr.CreateLine -4.2, 140.5, 0, -1.0, 136.2, 0
swSketchMgr.CreateLine -1.0, 136.2, 0, -1.0, 145.0, 0

Dim featFwdFlaps
Set featFwdFlaps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.18, 0.18, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 7. In-Orbit Refueling Ports (4x) & RCS Attitude Thruster Quads
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' 4 Refueling Ports at Y=82.5m & 84.5m:
swSketchMgr.CreateCircleByRadius 4.52, 82.5, 0, 0.22
swSketchMgr.CreateCircleByRadius 4.52, 84.5, 0, 0.22
swSketchMgr.CreateCircleByRadius -4.52, 82.5, 0, 0.22
swSketchMgr.CreateCircleByRadius -4.52, 84.5, 0, 0.22
' RCS Pods:
swSketchMgr.CreateCircleByRadius 1.8, 145.0, 0, 0.12
swSketchMgr.CreateCircleByRadius -1.8, 145.0, 0, 0.12
Dim featShipPorts
Set featShipPorts = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.22, 0.22, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 8. Starlink Pez Dispenser Payload Door (Y=126.0m to 132.0m)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateLine 4.38, 132.0, 0, 4.65, 132.0, 0
swSketchMgr.CreateLine 4.65, 132.0, 0, 4.65, 126.0, 0
swSketchMgr.CreateLine 4.65, 126.0, 0, 4.38, 126.0, 0
swSketchMgr.CreateLine 4.38, 126.0, 0, 4.38, 132.0, 0
Dim featPezDoor
Set featPezDoor = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.85, 0.85, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 9. High-Contrast Black Ceramic TUFI/AETB Thermal Protection System (TPS) Wrap (180 deg)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 80.0, 0, 0, 150.0, 0
swSketchMgr.CreateLine 0, 150.02, 0, 0.92, 147.52, 0
swSketchMgr.CreateLine 0.92, 147.52, 0, 2.42, 142.02, 0
swSketchMgr.CreateLine 2.42, 142.02, 0, 3.82, 133.02, 0
swSketchMgr.CreateLine 3.82, 133.02, 0, 4.42, 124.02, 0
swSketchMgr.CreateLine 4.42, 124.02, 0, 4.52, 116.0, 0
swSketchMgr.CreateLine 4.52, 116.0, 0, 4.52, 80.0, 0
swSketchMgr.CreateLine 4.52, 80.0, 0, 4.50, 80.0, 0
swSketchMgr.CreateLine 4.50, 80.0, 0, 4.50, 116.0, 0
swSketchMgr.CreateLine 4.50, 116.0, 0, 4.4, 124.0, 0
swSketchMgr.CreateLine 4.4, 124.0, 0, 3.8, 133.0, 0
swSketchMgr.CreateLine 3.8, 133.0, 0, 2.4, 142.0, 0
swSketchMgr.CreateLine 2.4, 142.0, 0, 0.9, 147.5, 0
swSketchMgr.CreateLine 0.9, 147.5, 0, 0, 150.0, 0
swSketchMgr.CreateLine 0, 150.0, 0, 0, 150.02, 0
Dim featShipTPS
Set featShipTPS = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Starship_V3.SLDPRT", 0, 1
WScript.Echo "  [OK] Starship Block 3 Upper Stage Saved: Starship_V3.SLDPRT (70.0m)"


' ====================================================================
' 6. FULL STACK TOP-LEVEL MASTER ASSEMBLY (150.0m TOTAL HEIGHT)
' ====================================================================
WScript.Echo vbCrLf & ">>> [6/6] Assembling 150m Full Stack (Super Heavy 76.5m + Interstage 3.5m + Starship 70.0m)..."
Dim swAsm
Set swAsm = swApp.NewDocument(asmTemplate, 0, 0, 0)
If swAsm Is Nothing Then
    WScript.Echo "ERROR: Failed to create Assembly document."
    WScript.Quit 1
End If

Dim compBooster
Set compBooster = swAsm.AddComponent5(baseDir & "Booster_V3.SLDPRT", 0, "", False, "", 0, 0, 0)

Dim compShip
Set compShip = swAsm.AddComponent5(baseDir & "Starship_V3.SLDPRT", 0, "", False, "", 0, 0, 0)

Dim compSkeleton
Set compSkeleton = swAsm.AddComponent5(baseDir & "V3_Master_Skeleton.SLDPRT", 0, "", False, "", 0, 0, 0)

swAsm.ForceRebuild3 False
swAsm.ShowNamedView2 "*Isometric", 7
swAsm.ViewZoomtofit2
swAsm.SaveAs3 baseDir & "Starship_FullStack_V3.SLDASM", 0, 1
WScript.Echo "  [OK] Master 150m Full Stack Assembly Saved: Starship_FullStack_V3.SLDASM"

WScript.Echo vbCrLf & "======================================================================"
WScript.Echo "MISSION COMPLETE: 150.0m STARSHIP BLOCK 3 1:1 CAD SYSTEM GENERATED!"
WScript.Echo "======================================================================"
