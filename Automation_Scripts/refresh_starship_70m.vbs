Option Explicit

Dim swApp, swModel, swDocExt, swFeatMgr, swSketchMgr
Dim boolstatus, two_pi, pi
two_pi = 6.283185307179586
pi = 3.141592653589793

Dim partTemplate, asmTemplate, baseDir
partTemplate = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"
asmTemplate  = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Assembly.ASMDOT"
baseDir      = "C:\Users\user\.gemini\antigravity\scratch\solidworks_rocket\starship_v3\"

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True
swApp.CloseAllDocuments True

WScript.Echo ">>> Building 70.0m Starship Block 3 Upper Stage..."
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
swSketchMgr.CreateCircleByRadius 4.52, 82.5, 0, 0.22
swSketchMgr.CreateCircleByRadius 4.52, 84.5, 0, 0.22
swSketchMgr.CreateCircleByRadius -4.52, 82.5, 0, 0.22
swSketchMgr.CreateCircleByRadius -4.52, 84.5, 0, 0.22
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
WScript.Echo "  [OK] Starship Block 3 Upper Stage Saved: Starship_V3.SLDPRT (70.0m Length)"

' Rebuild Master Assembly
WScript.Echo vbCrLf & ">>> Assembling 150.0m Master Assembly..."
Dim swAsm
Set swAsm = swApp.NewDocument(asmTemplate, 0, 0, 0)
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
WScript.Echo "  [OK] Master 150m Full Stack Assembly Refreshed: Starship_FullStack_V3.SLDASM"
