Dim swApp, swModel, nErrors, nWarnings
Set swApp = CreateObject("SldWorks.Application")
Set swModel = swApp.ActiveDoc
If Not swModel Is Nothing Then
    swModel.ShowNamedView2 "*Isometric", 7
    swModel.ViewZoomtofit2
    Dim savePath
    savePath = "C:\Users\user\.gemini\antigravity\scratch\solidworks_rocket\Aerospace_Rocket.SLDPRT"
    swModel.SaveAs3 savePath, 0, 1
    WScript.Echo "Rocket successfully saved to: " & savePath
Else
    WScript.Echo "No active document found."
End If
