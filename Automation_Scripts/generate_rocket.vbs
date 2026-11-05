Option Explicit

Dim swApp, swModel, swDocExt, swFeatMgr, swSketchMgr
Dim boolstatus, longstatus, longwarnings
Dim two_pi

two_pi = 6.283185307179586

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True

WScript.Echo "============================================================"
WScript.Echo "SOLIDWORKS 2026 - AEROSPACE ROCKET 3D GENERATOR"
WScript.Echo "============================================================"
WScript.Echo "SolidWorks Version: " & swApp.RevisionNumber

Dim template
template = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"

Set swModel = swApp.NewDocument(template, 0, 0, 0)
If swModel Is Nothing Then
    WScript.Echo "ERROR: Failed to initialize Part document."
    WScript.Quit 1
End If

Set swDocExt = swModel.Extension
Set swFeatMgr = swModel.FeatureManager
Set swSketchMgr = swModel.SketchManager

WScript.Echo "Part Document Initialized: " & swModel.GetTitle

' -------------------------------------------------------------
' 1. MAIN FUSELAGE, NOSE CONE & ENGINE BELL REVOLVE
' -------------------------------------------------------------
WScript.Echo vbCrLf & "[1/5] Modeling Main Fuselage, Aerodynamic Nose Cone & Engine Nozzle..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)

swSketchMgr.InsertSketch True

' Centerline
swSketchMgr.CreateCenterLine 0, 0, 0, 0, 0.320, 0

' Nose Cone (smooth multi-segment ogive profile from tip Y=320mm down to Y=220mm)
swSketchMgr.CreateLine 0, 0.320, 0, 0.006, 0.305, 0
swSketchMgr.CreateLine 0.006, 0.305, 0, 0.014, 0.280, 0
swSketchMgr.CreateLine 0.014, 0.280, 0, 0.021, 0.250, 0
swSketchMgr.CreateLine 0.021, 0.250, 0, 0.025, 0.220, 0

' Stage 2 Payload Fairing / Cylinder (Y=220mm down to Y=165mm)
swSketchMgr.CreateLine 0.025, 0.220, 0, 0.025, 0.165, 0

' Interstage Transition Ring / Collar
swSketchMgr.CreateLine 0.025, 0.165, 0, 0.0262, 0.163, 0
swSketchMgr.CreateLine 0.0262, 0.163, 0, 0.0262, 0.157, 0
swSketchMgr.CreateLine 0.0262, 0.157, 0, 0.025, 0.155, 0

' Main Stage 1 Booster Cylinder (Y=155mm down to Y=060mm)
swSketchMgr.CreateLine 0.025, 0.155, 0, 0.025, 0.060, 0

' Boattail Aft Taper (Y=60mm down to Y=35mm, R=25mm to R=18mm)
swSketchMgr.CreateLine 0.025, 0.060, 0, 0.018, 0.035, 0

' Engine Throat
swSketchMgr.CreateLine 0.018, 0.035, 0, 0.012, 0.025, 0

' Rocket Engine Nozzle Outer Bell (expands to R=20mm at base Y=2mm)
swSketchMgr.CreateLine 0.012, 0.025, 0, 0.020, 0.002, 0

' Engine Nozzle Lip Rim
swSketchMgr.CreateLine 0.020, 0.002, 0, 0.017, 0.002, 0

' Engine Inner Bell Expansion Cavity
swSketchMgr.CreateLine 0.017, 0.002, 0, 0.008, 0.025, 0
swSketchMgr.CreateLine 0.008, 0.025, 0, 0, 0.025, 0

' Centerline closure back to Nose Tip
swSketchMgr.CreateLine 0, 0.025, 0, 0, 0.320, 0

Dim featBody
Set featBody = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Fuselage, Nose Cone & Engine Bell created."

' -------------------------------------------------------------
' 2. AERODYNAMIC TAIL STABILIZER FINS
' -------------------------------------------------------------
WScript.Echo vbCrLf & "[2/5] Modeling Swept Aerodynamic Tail Fins..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

swSketchMgr.CreateLine 0.022, 0.075, 0, 0.072, 0.025, 0
swSketchMgr.CreateLine 0.072, 0.025, 0, 0.072, 0.008, 0
swSketchMgr.CreateLine 0.072, 0.008, 0, 0.016, 0.008, 0
swSketchMgr.CreateLine 0.016, 0.008, 0, 0.022, 0.075, 0

' Extrude MidPlane: Thickness = 3.2mm (0.0032m)
Dim featFin
Set featFin = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.0032, 0.0032, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Tail Fin extruded."

' -------------------------------------------------------------
' 3. CIRCULAR PATTERN (4x Symmetrical Fins)
' -------------------------------------------------------------
WScript.Echo vbCrLf & "[3/5] Creating 4x Circular Pattern of Stabilizers..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Boss-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 0.025, 0.100, 0, True, 1, Nothing, 0)

Dim featFinPattern
Set featFinPattern = swFeatMgr.FeatureCircularPattern4(4, two_pi, False, "NULL", False, True, False)
WScript.Echo "  -> 4x Fin Circular Pattern completed."

' -------------------------------------------------------------
' 4. DUAL SOLID ROCKET BOOSTERS (SRBs)
' -------------------------------------------------------------
WScript.Echo vbCrLf & "[4/5] Adding Dual Solid Rocket Boosters (SRBs)..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

Dim bx, br
bx = 0.034
br = 0.0085

' Booster centerline at X=34mm
swSketchMgr.CreateCenterLine bx, 0.006, 0, bx, 0.200, 0

' Booster Nose Cone
swSketchMgr.CreateLine bx, 0.200, 0, bx + br, 0.170, 0
' Booster Fuselage Body
swSketchMgr.CreateLine bx + br, 0.170, 0, bx + br, 0.020, 0
' Booster Boattail
swSketchMgr.CreateLine bx + br, 0.020, 0, bx + 0.0055, 0.010, 0
' Booster Nozzle
swSketchMgr.CreateLine bx + 0.0055, 0.010, 0, bx + 0.0075, 0.006, 0
swSketchMgr.CreateLine bx + 0.0075, 0.006, 0, bx, 0.006, 0
' Booster Centerline closure
swSketchMgr.CreateLine bx, 0.006, 0, bx, 0.200, 0

Dim featBooster
Set featBooster = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> First Booster body revolved."

' Booster Attachment Pylons / Struts
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

' Upper structural mount
swSketchMgr.CreateLine 0.020, 0.145, 0, 0.034, 0.145, 0
swSketchMgr.CreateLine 0.034, 0.145, 0, 0.034, 0.137, 0
swSketchMgr.CreateLine 0.034, 0.137, 0, 0.020, 0.137, 0
swSketchMgr.CreateLine 0.020, 0.137, 0, 0.020, 0.145, 0

' Lower structural mount
swSketchMgr.CreateLine 0.020, 0.055, 0, 0.034, 0.055, 0
swSketchMgr.CreateLine 0.034, 0.055, 0, 0.034, 0.047, 0
swSketchMgr.CreateLine 0.034, 0.047, 0, 0.020, 0.047, 0
swSketchMgr.CreateLine 0.020, 0.047, 0, 0.020, 0.055, 0

Dim featStruts
Set featStruts = swFeatMgr.FeatureExtrusion3(True, False, False, 6, 0, 0.0035, 0.0035, False, False, False, False, 0, 0, False, False, False, False, True, True, True, 0, 0, False)
WScript.Echo "  -> Mounting Pylons extruded."

' Circular pattern for 2x Boosters (180 degrees apart)
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Revolve2", "BODYFEATURE", 0, 0, 0, False, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("Boss-Extrude2", "BODYFEATURE", 0, 0, 0, True, 4, Nothing, 0)
boolstatus = swDocExt.SelectByID2("", "FACE", 0.025, 0.100, 0, True, 1, Nothing, 0)

Dim featBoosterPattern
Set featBoosterPattern = swFeatMgr.FeatureCircularPattern4(2, two_pi, False, "NULL", False, True, False)
WScript.Echo "  -> Dual Booster pattern created."

' -------------------------------------------------------------
' 5. NOSE PITOT PROBE / INSTRUMENTATION MAST & FINALIZE
' -------------------------------------------------------------
WScript.Echo vbCrLf & "[5/5] Adding Nose Pitot Sensor & Saving Model..."
swModel.ClearSelection2 True
boolstatus = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
swSketchMgr.InsertSketch True

swSketchMgr.CreateCenterLine 0, 0.320, 0, 0, 0.350, 0
swSketchMgr.CreateLine 0, 0.350, 0, 0.0012, 0.320, 0
swSketchMgr.CreateLine 0.0012, 0.320, 0, 0.0012, 0.320, 0
swSketchMgr.CreateLine 0.0012, 0.320, 0, 0, 0.320, 0
swSketchMgr.CreateLine 0, 0.320, 0, 0, 0.350, 0

Dim featProbe
Set featProbe = swFeatMgr.FeatureRevolve2(True, True, False, False, False, False, 0, 0, two_pi, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)
WScript.Echo "  -> Nose Pitot Probe added."

' Rebuild document
swModel.ForceRebuild3 False

' Set Isometric View & Zoom to Fit
swModel.ShowNamedView2 "*Isometric", 7
swModel.ViewZoomtofit2

' Save Part
Dim savePath
savePath = "C:\Users\user\.gemini\antigravity\scratch\solidworks_rocket\Aerospace_Rocket.SLDPRT"

Dim errs, warns
errs = 0
warns = 0
swModel.SaveAs3 savePath, 0, 1

WScript.Echo vbCrLf & "============================================================"
WScript.Echo "SUCCESS: Aerospace Rocket 3D Model created in SolidWorks!"
WScript.Echo "Saved file: " & savePath
WScript.Echo "============================================================"
