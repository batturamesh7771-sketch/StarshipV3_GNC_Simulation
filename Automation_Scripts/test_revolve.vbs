Dim swApp, swModel, boolstatus

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True
WScript.Echo "SolidWorks Version: " & swApp.RevisionNumber

Dim template
template = "C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"

Set swModel = swApp.NewDocument(template, 0, 0, 0)
If swModel Is Nothing Then
    WScript.Echo "Failed to create document."
    WScript.Quit 1
End If

WScript.Echo "Document created: " & swModel.GetTitle

boolstatus = swModel.Extension.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, Nothing, 0)
WScript.Echo "Selected Front Plane: " & boolstatus

swModel.SketchManager.InsertSketch True
swModel.SketchManager.CreateCenterLine 0, 0, 0, 0, 0.3, 0
swModel.SketchManager.CreateLine 0, 0.3, 0, 0.025, 0.2, 0
swModel.SketchManager.CreateLine 0.025, 0.2, 0, 0.025, 0.05, 0
swModel.SketchManager.CreateLine 0.025, 0.05, 0, 0, 0.05, 0
swModel.SketchManager.CreateLine 0, 0.05, 0, 0, 0.3, 0

Dim featRevolve
Set featRevolve = swModel.FeatureManager.FeatureRevolve2(True, True, False, False, False, False, 0, 0, 6.283185307179586, 0, False, False, 0.01, 0.01, 0, 0, 0, True, True, True)

WScript.Echo "Revolved feature created: " & Not (featRevolve Is Nothing)
swModel.ViewZoomtofit2
