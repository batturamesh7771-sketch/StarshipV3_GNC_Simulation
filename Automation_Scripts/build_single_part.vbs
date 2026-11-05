Option Explicit

Dim swApp, swModel, swDocExt, swFeatMgr, swSketchMgr
Dim boolstatus, two_pi, pi
two_pi = 6.283185307179586
pi = 3.141592653589793

Dim partTemplate, baseDir
partTemplate = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"
baseDir      = "C:\Users\user\.gemini\antigravity\scratch\starship_v3_master_3d\"

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True

WScript.Echo "Generating Unified 150m Single-Part Solid Model..."
Set swModel = swApp.NewDocument(partTemplate, 0, 0, 0)
Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

' 1. Revolve Booster Main Hull (Y=0 to Y=76.5)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 150.0, 0

swSketchMgr.CreateLine 0, 76.5, 0, 4.50, 76.5, 0
swSketchMgr.CreateLine 4.50, 76.5, 0, 4.50, 1.0, 0
swSketchMgr.CreateLine 4.50, 1.0, 0, 4.62, 0.0, 0
swSketchMgr.CreateLine 4.62, 0.0, 0, 4.30, 0.0, 0
swSketchMgr.CreateLine 4.30, 0.0, 0, 4.30, 1.5, 0
swSketchMgr.CreateLine 4.30, 1.5, 0, 4.30, 73.0, 0
swSketchMgr.CreateLine 4.30, 73.0, 0, 0, 75.0, 0
swSketchMgr.CreateLine 0, 75.0, 0, 0, 76.5, 0
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' 2. Revolve Hot-Staging Ring (Y=76.5 to Y=80.0)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 150.0, 0
swSketchMgr.CreateLine 0, 80.0, 0, 4.50, 80.0, 0
swSketchMgr.CreateLine 4.50, 80.0, 0, 4.50, 76.5, 0
swSketchMgr.CreateLine 4.50, 76.5, 0, 4.32, 76.5, 0
swSketchMgr.CreateLine 4.32, 76.5, 0, 4.32, 79.5, 0
swSketchMgr.CreateLine 4.32, 79.5, 0, 0, 80.0, 0
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' 3. Revolve Starship Stage 2 Hull (Y=80.0 to Y=150.0)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 150.0, 0
' Cylindrical barrel section
swSketchMgr.CreateLine 0, 80.0, 0, 4.50, 80.0, 0
swSketchMgr.CreateLine 4.50, 80.0, 0, 4.50, 116.0, 0
' Ogive curve
swSketchMgr.CreateSpline "0, 150.0, 0, 0.90, 147.0, 0, 2.50, 137.0, 0, 3.80, 126.0, 0, 4.50, 116.0, 0"
' Inner skin
swSketchMgr.CreateSpline "0, 149.2, 0, 0.85, 146.5, 0, 2.38, 136.5, 0, 3.65, 125.5, 0, 4.35, 115.5, 0"
swSketchMgr.CreateLine 4.35, 115.5, 0, 4.35, 81.5, 0
swSketchMgr.CreateLine 4.35, 81.5, 0, 0, 80.0, 0
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' 4. Booster 33 Raptors
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, -1.0, 0, 0, 4.0, 0
swSketchMgr.CreateLine 0, 3.0, 0, 0.65, -0.45, 0
swSketchMgr.CreateLine 0.65, -0.45, 0, 0.58, -0.45, 0
swSketchMgr.CreateLine 0.58, -0.45, 0, 0, 2.7, 0
swSketchMgr.CreateLine 0, 2.7, 0, 0, 3.0, 0

swSketchMgr.CreateLine 1.60, 2.6, 0, 2.45, -0.45, 0
swSketchMgr.CreateLine 2.45, -0.45, 0, 2.35, -0.45, 0
swSketchMgr.CreateLine 2.35, -0.45, 0, 1.70, 2.6, 0
swSketchMgr.CreateLine 1.70, 2.6, 0, 1.60, 2.6, 0

swSketchMgr.CreateLine 3.25, 2.4, 0, 4.25, -0.45, 0
swSketchMgr.CreateLine 4.25, -0.45, 0, 4.15, -0.45, 0
swSketchMgr.CreateLine 4.15, -0.45, 0, 3.35, 2.4, 0
swSketchMgr.CreateLine 3.35, 2.4, 0, 3.25, 2.4, 0
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' 5. Starship 9 Raptors
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 78.0, 0, 0, 84.0, 0
swSketchMgr.CreateLine 0, 83.0, 0, 0.70, 79.5, 0
swSketchMgr.CreateLine 0.70, 79.5, 0, 0.62, 79.5, 0
swSketchMgr.CreateLine 0.62, 79.5, 0, 0, 82.7, 0
swSketchMgr.CreateLine 0, 82.7, 0, 0, 83.0, 0

swSketchMgr.CreateLine 1.45, 83.2, 0, 3.85, 78.8, 0
swSketchMgr.CreateLine 3.85, 78.8, 0, 3.75, 78.8, 0
swSketchMgr.CreateLine 3.75, 78.8, 0, 1.55, 83.2, 0
swSketchMgr.CreateLine 1.55, 83.2, 0, 1.45, 83.2, 0
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' 6. Booster Grid Fins (4x 3.0m x 2.2m with Waffle Lattice)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateLine 3.8, 74.0, 0, 7.5, 73.2, 0
swSketchMgr.CreateLine 7.5, 73.2, 0, 7.5, 70.2, 0
swSketchMgr.CreateLine 7.5, 70.2, 0, 3.8, 69.8, 0
swSketchMgr.CreateLine 3.8, 69.8, 0, 3.8, 74.0, 0
swSketchMgr.CreateCircleByRadius 4.6, 69.0, 0, 0.22
swFeatMgr.FeatureExtrusion3 True, False, False, 6, 0, 0.32, 0.32, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
Dim gx, gy
For gx = 4.8 To 7.0 Step 0.65
    For gy = 70.6 To 72.8 Step 0.65
        swSketchMgr.CreateLine gx, gy, 0, gx + 0.45, gy, 0
        swSketchMgr.CreateLine gx + 0.45, gy, 0, gx + 0.45, gy + 0.45, 0
        swSketchMgr.CreateLine gx + 0.45, gy + 0.45, 0, gx, gy + 0.45, 0
        swSketchMgr.CreateLine gx, gy + 0.45, 0, gx, gy, 0
    Next
Next
swFeatMgr.FeatureCut4 True, False, False, 6, 0, 0.40, 0.40, False, False, False, False, 0, 0, False, False, False, False, False, True, True, True, True, False, 0, 0, False, False

swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Boss-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("Cut-Extrude1", "BODYFEATURE", 0, 0, 0, True, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 4.5, 35.0, 0, True, 1, Nothing, 0)
swFeatMgr.FeatureCircularPattern4 4, two_pi, False, "NULL", False, True, False

' 7. Starship 11.5m Solid Volumetric Aft Flaps (Zero-Gap)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Port Flap
swSketchMgr.CreateLine 3.60, 93.5, 0, 9.40, 87.2, 0
swSketchMgr.CreateLine 9.40, 87.2, 0, 8.80, 82.0, 0
swSketchMgr.CreateLine 8.80, 82.0, 0, 3.60, 82.0, 0
swSketchMgr.CreateLine 3.60, 82.0, 0, 3.60, 93.5, 0
swSketchMgr.CreateCircleByRadius 4.45, 87.75, 0, 0.55
' Starboard Flap
swSketchMgr.CreateLine -3.60, 93.5, 0, -9.40, 87.2, 0
swSketchMgr.CreateLine -9.40, 87.2, 0, -8.80, 82.0, 0
swSketchMgr.CreateLine -8.80, 82.0, 0, -3.60, 82.0, 0
swSketchMgr.CreateLine -3.60, 82.0, 0, -3.60, 93.5, 0
swSketchMgr.CreateCircleByRadius -4.45, 87.75, 0, 0.55
swFeatMgr.FeatureExtrusion3 True, False, False, 6, 0, 0.38, 0.38, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False

' 8. Starship Solid Volumetric Forward Flaps
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
' Port Forward Flap
swSketchMgr.CreateLine 2.20, 142.0, 0, 6.20, 137.5, 0
swSketchMgr.CreateLine 6.20, 137.5, 0, 5.80, 133.5, 0
swSketchMgr.CreateLine 5.80, 133.5, 0, 3.20, 134.5, 0
swSketchMgr.CreateLine 3.20, 134.5, 0, 2.20, 142.0, 0
swSketchMgr.CreateCircleByRadius 3.20, 138.0, 0, 0.40
' Starboard Forward Flap
swSketchMgr.CreateLine -2.20, 142.0, 0, -6.20, 137.5, 0
swSketchMgr.CreateLine -6.20, 137.5, 0, -5.80, 133.5, 0
swSketchMgr.CreateLine -5.80, 133.5, 0, -3.20, 134.5, 0
swSketchMgr.CreateLine -3.20, 134.5, 0, -2.20, 142.0, 0
swSketchMgr.CreateCircleByRadius -3.20, 138.0, 0, 0.40
swFeatMgr.FeatureExtrusion3 True, False, False, 6, 0, 0.30, 0.30, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False

' 9. Roll Rings across vehicle
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 150.0, 0
Dim y_all
For y_all = 1.8 To 115.0 Step 1.8
    swSketchMgr.CreateCircleByRadius 4.506, y_all, 0, 0.010
Next
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' 10. Thermal Protection System (180 deg black ceramic shield)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 150.0, 0
swSketchMgr.CreateLine 0, 150.06, 0, 0.94, 147.06, 0
swSketchMgr.CreateLine 0.94, 147.06, 0, 2.54, 137.06, 0
swSketchMgr.CreateLine 2.54, 137.06, 0, 3.84, 126.06, 0
swSketchMgr.CreateLine 3.84, 126.06, 0, 4.54, 116.0, 0
swSketchMgr.CreateLine 4.54, 116.0, 0, 4.54, 80.5, 0
swSketchMgr.CreateLine 4.54, 80.5, 0, 4.50, 80.5, 0
swSketchMgr.CreateLine 4.50, 80.5, 0, 4.50, 116.0, 0
swSketchMgr.CreateLine 4.50, 116.0, 0, 3.80, 126.0, 0
swSketchMgr.CreateLine 3.80, 126.0, 0, 2.50, 137.0, 0
swSketchMgr.CreateLine 2.50, 137.0, 0, 0.90, 147.0, 0
swSketchMgr.CreateLine 0.90, 147.0, 0, 0, 150.0, 0
swSketchMgr.CreateLine 0, 150.0, 0, 0, 150.06, 0
swFeatMgr.FeatureRevolve2 True, True, False, False, False, False, 0, 0, pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True

' Save
swModel.ForceRebuild3 False
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2
swModel.SaveAs3 baseDir & "Starship_Block3_150m_SinglePart.SLDPRT", 0, 1
WScript.Echo "SUCCESS: Saved Starship_Block3_150m_SinglePart.SLDPRT"
