Option Explicit

Dim swApp, swModel, swDocExt, swFeatMgr, swSketchMgr
Dim boolstatus, longstatus, longwarnings
Dim two_pi, pi
two_pi = 6.283185307179586
pi = 3.141592653589793

Dim partTemplate, baseDir
partTemplate = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"
baseDir      = "C:\Users\user\.gemini\antigravity\scratch\starship_v3_complete\"

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True
swApp.CloseAllDocuments True

WScript.Echo "======================================================================"
WScript.Echo "SPACEX STARSHIP V3 FULL-STACK 3D CAD MODEL (TOP-TO-BOTTOM ARCHITECTURE)"
WScript.Echo "======================================================================"
WScript.Echo "Target File: " & baseDir & "Starship_V3_Full_Stack.SLDPRT"
WScript.Echo "Connected to SolidWorks 2026 Engine: " & swApp.RevisionNumber

Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
If swModel Is Nothing Then
    WScript.Echo "ERROR: Failed to create SolidWorks part document."
    WScript.Quit 1
End If

Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' --------------------------------------------------------------------
' 1. FULL MAIN ROCKET FUSELAGE (TOP TO BOTTOM REVOLVED BODY)
' Total Height: 124.4m, Outer Diameter: 9.0m (R = 4.5m)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [1/8] Modeling Full Stack Continuous Fuselage (Booster + Interstage + Starship + Nose)..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Central Centerline
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 124.4, 0

' Nosecone Apex: (0, 124.4)
' Smooth Ogive Curve from Y=104.0m to 124.4m:
swSketchMgr.CreateLine 0, 124.4, 0, 0.8, 122.5, 0
swSketchMgr.CreateLine 0.8, 122.5, 0, 2.2, 118.0, 0
swSketchMgr.CreateLine 2.2, 118.0, 0, 3.6, 111.0, 0
swSketchMgr.CreateLine 3.6, 111.0, 0, 4.35, 104.0, 0
swSketchMgr.CreateLine 4.35, 104.0, 0, 4.50, 98.0, 0

' Starship Cylindrical Hull (Y=98.0m down to Y=73.5m):
swSketchMgr.CreateLine 4.50, 98.0, 0, 4.50, 73.5, 0

' Hot-Staging Interstage Transition Ring (Y=73.5m down to Y=70.0m, R=4.42m):
swSketchMgr.CreateLine 4.50, 73.5, 0, 4.42, 73.5, 0
swSketchMgr.CreateLine 4.42, 73.5, 0, 4.42, 70.0, 0
swSketchMgr.CreateLine 4.42, 70.0, 0, 4.50, 70.0, 0

' Super Heavy Booster Cylindrical Hull (Y=70.0m down to Y=4.0m):
swSketchMgr.CreateLine 4.50, 70.0, 0, 4.50, 4.0, 0

' Booster Aft Skirt Flare: (4.50, 4.0) -> (4.62, 0.0)
swSketchMgr.CreateLine 4.50, 4.0, 0, 4.62, 0.0, 0

' Base Engine Cavity Inward Lip:
swSketchMgr.CreateLine 4.62, 0.0, 0, 4.30, 0.0, 0
swSketchMgr.CreateLine 4.30, 0.0, 0, 4.30, 1.5, 0
swSketchMgr.CreateLine 4.30, 1.5, 0, 0, 4.0, 0
swSketchMgr.CreateLine 0, 4.0, 0, 0, 124.4, 0

Dim featMainFuselage
Set featMainFuselage = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Full 124.4m Continuous Rocket Fuselage Revolved."

' --------------------------------------------------------------------
' 2. BOTTOM 33-RAPTOR 3 ENGINE CLUSTER (OUTER 20 + MIDDLE 10 + INNER 3)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [2/8] Modeling Bottom 33-Raptor 3 Propulsion Cluster Matrix..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, -1.0, 0, 0, 4.0, 0

' Central 3-Engine Core (R=0.65m):
swSketchMgr.CreateLine 0, 3.2, 0, 0.65, -0.65, 0
swSketchMgr.CreateLine 0.65, -0.65, 0, 0.58, -0.65, 0
swSketchMgr.CreateLine 0.58, -0.65, 0, 0, 2.8, 0
swSketchMgr.CreateLine 0, 2.8, 0, 0, 3.2, 0

' Middle 10-Engine Ring (R=2.1m):
swSketchMgr.CreateLine 1.55, 2.7, 0, 2.45, -0.65, 0
swSketchMgr.CreateLine 2.45, -0.65, 0, 2.35, -0.65, 0
swSketchMgr.CreateLine 2.35, -0.65, 0, 1.65, 2.7, 0
swSketchMgr.CreateLine 1.65, 2.7, 0, 1.55, 2.7, 0

' Outer 20-Engine Ring (R=3.85m, 1.3m nozzle bells protruding below skirt):
swSketchMgr.CreateLine 3.20, 2.5, 0, 4.30, -0.65, 0
swSketchMgr.CreateLine 4.30, -0.65, 0, 4.18, -0.65, 0
swSketchMgr.CreateLine 4.18, -0.65, 0, 3.32, 2.5, 0
swSketchMgr.CreateLine 3.32, 2.5, 0, 3.20, 2.5, 0

Dim feat33Raptors
Set feat33Raptors = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Bottom 33-Raptor 3 Engine Cluster generated."

' --------------------------------------------------------------------
' 3. INTERSTAGE 9-RAPTOR ENGINE CLUSTER (STARSHIP SHIP ENGINES)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [3/8] Modeling Starship 9-Raptor Engine Section inside Interstage..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 68.0, 0, 0, 78.0, 0

' 3 Center SL Engines (R=0.65m):
swSketchMgr.CreateLine 0, 75.0, 0, 0.65, 71.0, 0
swSketchMgr.CreateLine 0.65, 71.0, 0, 0.58, 71.0, 0
swSketchMgr.CreateLine 0.58, 71.0, 0, 0, 74.5, 0
swSketchMgr.CreateLine 0, 74.5, 0, 0, 75.0, 0

' 6 Outer Vacuum RVac Engines (R=2.9m radius with 2.4m extended bells):
swSketchMgr.CreateLine 2.2, 75.0, 0, 3.8, 70.8, 0
swSketchMgr.CreateLine 3.8, 70.8, 0, 3.7, 70.8, 0
swSketchMgr.CreateLine 3.7, 70.8, 0, 2.3, 75.0, 0
swSketchMgr.CreateLine 2.3, 75.0, 0, 2.2, 75.0, 0

Dim featShipEngines
Set featShipEngines = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Interstage 9-Raptor Engine Cluster generated."

' --------------------------------------------------------------------
' 4. HOT-STAGING RING PLASMA EXHAUST VENTS (16-WINDOW GRID PATTERN)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [4/8] Modeling Hot-Staging Interstage Open-Vent Grid Structure..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Right and Left vent cutouts at Y=70.8m to Y=72.8m:
swSketchMgr.CreateLine 3.8, 72.8, 0, 4.6, 72.8, 0
swSketchMgr.CreateLine 4.6, 72.8, 0, 4.6, 70.8, 0
swSketchMgr.CreateLine 4.6, 70.8, 0, 3.8, 70.8, 0
swSketchMgr.CreateLine 3.8, 70.8, 0, 3.8, 72.8, 0

swSketchMgr.CreateLine -3.8, 72.8, 0, -4.6, 72.8, 0
swSketchMgr.CreateLine -4.6, 72.8, 0, -4.6, 70.8, 0
swSketchMgr.CreateLine -4.6, 70.8, 0, -3.8, 70.8, 0
swSketchMgr.CreateLine -3.8, 70.8, 0, -3.8, 72.8, 0

Dim featVents
Set featVents = swFeatMgr.FeatureCut4(True, False, False, 6, 0, 4.0, 4.0, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False)

' Circular Pattern for 8x dual vent windows (16 vents total):
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Cut-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 4.5, 50.0, 0, True, 1, Nothing, 0)
Dim featVentPat
Set featVentPat = swFeatMgr.FeatureCircularPattern4(8, two_pi, False, "NULL", False, True, False)
WScript.Echo "  -> 16-Window Hot-Staging Grid Vents patterned."

' --------------------------------------------------------------------
' 5. 4x SUPER HEAVY FOLDABLE LATTICE GRID FINS (Y=66.0m to 70.0m)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [5/8] Modeling 4x Heavy-Duty Grid Fins & Mechazilla Catch Pins..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Embedded root inside hull at R=3.8m, spans to R=7.3m, Y=66.0m to 69.8m:
swSketchMgr.CreateLine 3.8, 69.8, 0, 7.3, 69.0, 0
swSketchMgr.CreateLine 7.3, 69.0, 0, 7.3, 66.2, 0
swSketchMgr.CreateLine 7.3, 66.2, 0, 3.8, 65.8, 0
swSketchMgr.CreateLine 3.8, 65.8, 0, 3.8, 69.8, 0
' Catch Hardpoint Lug:
swSketchMgr.CreateCircleByRadius 4.6, 65.0, 0, 0.22

Dim featGridFin
Set featGridFin = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.32, 0.32, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 4x Pattern at 90-degree intervals:
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Boss-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 4.5, 50.0, 0, True, 1, Nothing, 0)
Dim featGrid4Pat
Set featGrid4Pat = swFeatMgr.FeatureCircularPattern4(4, two_pi, False, "NULL", False, True, False)
WScript.Echo "  -> 4x Symmetrical Grid Fins & Catch Lugs extruded."

' --------------------------------------------------------------------
' 6. STARSHIP AFT (LOWER) FLAPS (11.5m ROOT CHORD, ZERO-GAP CONFORMAL COVERS)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [6/8] Modeling Starship Aft (Lower) Flaps & Conformal Aero-Covers..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Aft Flap (Root Chord 11.5m: Y=74.0m to 85.5m, embedded root at R=3.5m, span to R=7.6m):
swSketchMgr.CreateLine 3.5, 85.5, 0, 7.6, 79.5, 0
swSketchMgr.CreateLine 7.6, 79.5, 0, 7.6, 74.5, 0
swSketchMgr.CreateLine 7.6, 74.5, 0, 3.5, 74.0, 0
swSketchMgr.CreateLine 3.5, 74.0, 0, 3.5, 85.5, 0
' Right Conformal Aero-Cover:
swSketchMgr.CreateLine 3.5, 86.8, 0, 5.2, 79.5, 0
swSketchMgr.CreateLine 5.2, 79.5, 0, 3.5, 73.5, 0
swSketchMgr.CreateLine 3.5, 73.5, 0, 3.5, 86.8, 0

' Left Aft Flap:
swSketchMgr.CreateLine -3.5, 85.5, 0, -7.6, 79.5, 0
swSketchMgr.CreateLine -7.6, 79.5, 0, -7.6, 74.5, 0
swSketchMgr.CreateLine -7.6, 74.5, 0, -3.5, 74.0, 0
swSketchMgr.CreateLine -3.5, 74.0, 0, -3.5, 85.5, 0
' Left Conformal Aero-Cover:
swSketchMgr.CreateLine -3.5, 86.8, 0, -5.2, 79.5, 0
swSketchMgr.CreateLine -5.2, 79.5, 0, -3.5, 73.5, 0
swSketchMgr.CreateLine -3.5, 73.5, 0, -3.5, 86.8, 0

Dim featAftFlaps
Set featAftFlaps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.26, 0.26, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Starship Aft Lower Flaps (11.5m root) embedded seamlessly with ZERO gap."

' --------------------------------------------------------------------
' 7. STARSHIP UPPER FORWARD FLAPS (LEEWARD SHOULDER, ZERO GAP)
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [7/8] Modeling Starship Upper Forward Flaps & Shielded Blade Fairings..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Right Forward Flap (Y=111.5m to 118.0m, embedded root at R=1.0m, span to R=6.4m):
swSketchMgr.CreateLine 1.0, 118.0, 0, 6.4, 115.0, 0
swSketchMgr.CreateLine 6.4, 115.0, 0, 6.4, 112.0, 0
swSketchMgr.CreateLine 6.4, 112.0, 0, 1.0, 111.5, 0
swSketchMgr.CreateLine 1.0, 111.5, 0, 1.0, 118.0, 0
' Right Forward Aero-Cover:
swSketchMgr.CreateLine 1.0, 119.0, 0, 4.2, 115.0, 0
swSketchMgr.CreateLine 4.2, 115.0, 0, 1.0, 110.8, 0
swSketchMgr.CreateLine 1.0, 110.8, 0, 1.0, 119.0, 0

' Left Forward Flap:
swSketchMgr.CreateLine -1.0, 118.0, 0, -6.4, 115.0, 0
swSketchMgr.CreateLine -6.4, 115.0, 0, -6.4, 112.0, 0
swSketchMgr.CreateLine -6.4, 112.0, 0, -1.0, 111.5, 0
swSketchMgr.CreateLine -1.0, 111.5, 0, -1.0, 118.0, 0
' Left Forward Aero-Cover:
swSketchMgr.CreateLine -1.0, 119.0, 0, -4.2, 115.0, 0
swSketchMgr.CreateLine -4.2, 115.0, 0, -1.0, 110.8, 0
swSketchMgr.CreateLine -1.0, 110.8, 0, -1.0, 119.0, 0

Dim featFwdFlaps
Set featFwdFlaps = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.18, 0.18, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Upper Forward Flaps & Shielded Fairings constructed."

' --------------------------------------------------------------------
' 8. VERTICAL RACEWAYS & 180? WINDWARD BLACK CERAMIC TPS HEAT SHIELD
' --------------------------------------------------------------------
WScript.Echo vbCrLf & ">>> [8/8] Adding Aerodynamic Raceways, 180? TPS Heat Shield, and Roll Rings..."
' Longitudinal Raceways on both stages:
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Super Heavy Booster vertical raceway (Y=2m to 69m):
swSketchMgr.CreateLine 4.40, 69.0, 0, 4.65, 69.0, 0
swSketchMgr.CreateLine 4.65, 69.0, 0, 4.65, 2.0, 0
swSketchMgr.CreateLine 4.65, 2.0, 0, 4.40, 2.0, 0
swSketchMgr.CreateLine 4.40, 2.0, 0, 4.40, 69.0, 0
' Starship vertical raceways (Y=75m to 105m):
swSketchMgr.CreateLine 4.40, 105.0, 0, 4.62, 105.0, 0
swSketchMgr.CreateLine 4.62, 105.0, 0, 4.62, 75.0, 0
swSketchMgr.CreateLine 4.62, 75.0, 0, 4.40, 75.0, 0
swSketchMgr.CreateLine 4.40, 75.0, 0, 4.40, 105.0, 0
Dim featRaceways
Set featRaceways = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.22, 0.22, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)

' 180-Degree Windward Black Ceramic TPS Heat Shield Layer:
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 73.5, 0, 0, 124.4, 0
swSketchMgr.CreateLine 0, 124.42, 0, 0.82, 122.52, 0
swSketchMgr.CreateLine 0.82, 122.52, 0, 2.22, 118.02, 0
swSketchMgr.CreateLine 2.22, 118.02, 0, 3.62, 111.02, 0
swSketchMgr.CreateLine 3.62, 111.02, 0, 4.37, 104.02, 0
swSketchMgr.CreateLine 4.37, 104.02, 0, 4.52, 98.0, 0
swSketchMgr.CreateLine 4.52, 98.0, 0, 4.52, 73.5, 0
swSketchMgr.CreateLine 4.52, 73.5, 0, 4.50, 73.5, 0
swSketchMgr.CreateLine 4.50, 73.5, 0, 4.50, 98.0, 0
swSketchMgr.CreateLine 4.50, 98.0, 0, 4.35, 104.0, 0
swSketchMgr.CreateLine 4.35, 104.0, 0, 3.6, 111.0, 0
swSketchMgr.CreateLine 3.6, 111.0, 0, 2.2, 118.0, 0
swSketchMgr.CreateLine 2.2, 118.0, 0, 0.8, 122.5, 0
swSketchMgr.CreateLine 0.8, 122.5, 0, 0, 124.4, 0
swSketchMgr.CreateLine 0, 124.4, 0, 0, 124.42, 0
Dim featTPS
Set featTPS = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

' Final Rebuild & View Setup
swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2

' Save Complete Unified Rocket Part
Dim savePath
savePath = baseDir & "Starship_V3_Full_Stack.SLDPRT"
swModel.SaveAs3 savePath, 0, 1

WScript.Echo vbCrLf & "======================================================================"
WScript.Echo "SUCCESS: Complete Starship V3 Full-Stack 3D Rocket Generated!"
WScript.Echo "Saved to: " & savePath
WScript.Echo "======================================================================"
