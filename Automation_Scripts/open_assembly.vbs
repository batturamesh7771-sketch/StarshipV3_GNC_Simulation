Option Explicit
Dim swApp, swModel, baseDir, errors, warnings
baseDir = "C:\Users\user\.gemini\antigravity\scratch\starship_v3_master_3d\"

Set swApp = CreateObject("SldWorks.Application")
swApp.Visible = True
swApp.CloseAllDocuments True

Set swModel = swApp.OpenDoc6(baseDir & "Starship_Block3_FullStack_150m.SLDASM", 2, 0, "", errors, warnings)
If Not swModel Is Nothing Then
    swModel.ShowNamedView2 "*Isometric", 7
    swModel.ViewZoomtofit2
    WScript.Echo "SUCCESS: Starship_Block3_FullStack_150m.SLDASM successfully opened in SolidWorks viewport."
Else
    WScript.Echo "Error opening document. Error code: " & errors
End If
