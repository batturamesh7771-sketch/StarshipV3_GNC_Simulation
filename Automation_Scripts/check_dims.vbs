Dim swApp, swModel
Set swApp = CreateObject("SldWorks.Application")
Set swModel = swApp.OpenDoc6("C:\Users\user\.gemini\antigravity\scratch\solidworks_rocket\starship_v3\Starship_V3.SLDPRT", 1, 0, "", 0, 0)
If Not swModel Is Nothing Then
    Dim box
    box = swModel.GetPartBox(True)
    WScript.Echo "Starship_V3 Bound Box Y: " & box(1) & " to " & box(4)
    WScript.Echo "Height: " & (box(4) - box(1)) & " meters"
End If
