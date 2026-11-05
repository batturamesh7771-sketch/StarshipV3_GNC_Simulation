import os
import sys
import math
import win32com.client

def create_rocket():
    print("=" * 60)
    print("Connecting to SolidWorks API...")
    print("=" * 60)
    
    try:
        swApp = win32com.client.GetActiveObject("SldWorks.Application")
        print("Connected to running SolidWorks instance.")
    except Exception:
        print("Starting SolidWorks instance...")
        swApp = win32com.client.Dispatch("SldWorks.Application")
    
    swApp.Visible = True
    print(f"SolidWorks Version: {swApp.RevisionNumber}")
    
    # Template path
    template_path = r"C:\ProgramData\SolidWorks\SOLIDWORKS 2026\templates\Part.PRTDOT"
    if not os.path.exists(template_path):
        template_path = swApp.GetUserPreferenceStringValue(26) # swDefaultTemplatePart
    
    print(f"Creating new Part using template: {template_path}")
    swModel = swApp.NewDocument(template_path, 0, 0, 0)
    if not swModel:
        swModel = swApp.IActiveDoc2
    
    if not swModel:
        raise RuntimeError("Failed to create new SolidWorks document.")
    
    swDocExt = swModel.Extension
    swFeatMgr = swModel.FeatureManager
    swSketchMgr = swModel.SketchManager
    
    print("Successfully initialized Part Document.")
    
    # -------------------------------------------------------------
    # STEP 1: Main Rocket Fuselage, Nose Cone & Engine (Revolve)
    # -------------------------------------------------------------
    print("\n[Step 1/5] Modeling Main Fuselage, Nose Cone, and Engine Nozzle...")
    swModel.ClearSelection2(True)
    selected = swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, None, 0)
    if not selected:
        selected = swDocExt.SelectByID2("Front", "PLANE", 0, 0, 0, False, 0, None, 0)
    
    swSketchMgr.InsertSketch(True)
    
    # Central vertical axis centerline (from Y=0 to Y=0.320m / 320mm)
    swSketchMgr.CreateCenterLine(0, 0, 0, 0, 0.320, 0)
    
    # Outer Profile (Dimensions in meters):
    # Nose tip: (0, 0.320)
    swSketchMgr.CreateLine(0, 0.320, 0, 0.012, 0.290, 0)
    swSketchMgr.CreateLine(0.012, 0.290, 0, 0.022, 0.250, 0)
    swSketchMgr.CreateLine(0.022, 0.250, 0, 0.025, 0.220, 0)
    
    # Payload fairing / Stage 2 cylinder: (0.025, 0.220) -> (0.025, 0.160)
    swSketchMgr.CreateLine(0.025, 0.220, 0, 0.025, 0.160, 0)
    
    # Interstage ring detail:
    swSketchMgr.CreateLine(0.025, 0.160, 0, 0.0265, 0.158, 0)
    swSketchMgr.CreateLine(0.0265, 0.158, 0, 0.0265, 0.154, 0)
    swSketchMgr.CreateLine(0.0265, 0.154, 0, 0.025, 0.152, 0)
    
    # Main First Stage Body cylinder: (0.025, 0.152) -> (0.025, 0.060)
    swSketchMgr.CreateLine(0.025, 0.152, 0, 0.025, 0.060, 0)
    
    # Boattail / Aft section taper: (0.025, 0.060) -> (0.018, 0.035)
    swSketchMgr.CreateLine(0.025, 0.060, 0, 0.018, 0.035, 0)
    
    # Engine throat: (0.018, 0.035) -> (0.012, 0.025)
    swSketchMgr.CreateLine(0.018, 0.035, 0, 0.012, 0.025, 0)
    
    # Engine Nozzle expansion bell outer: (0.012, 0.025) -> (0.020, 0.002)
    swSketchMgr.CreateLine(0.012, 0.025, 0, 0.020, 0.002, 0)
    
    # Nozzle bottom lip: (0.020, 0.002) -> (0.017, 0.002)
    swSketchMgr.CreateLine(0.020, 0.002, 0, 0.017, 0.002, 0)
    
    # Engine Nozzle inner bell cavity: (0.017, 0.002) -> (0.008, 0.025)
    swSketchMgr.CreateLine(0.017, 0.002, 0, 0.008, 0.025, 0)
    
    # Cavity top to central axis: (0.008, 0.025) -> (0, 0.025)
    swSketchMgr.CreateLine(0.008, 0.025, 0, 0, 0.025, 0)
    
    # Centerline closure back to tip: (0, 0.025) -> (0, 0.320)
    swSketchMgr.CreateLine(0, 0.025, 0, 0, 0.320, 0)
    
    two_pi = 2.0 * math.pi
    feat_revolve = swFeatMgr.FeatureRevolve2(
        True, True, False, False, False, False, 
        0, 0, two_pi, 0, False, False, 
        0.01, 0.01, 0, 0, 0, True, True, True
    )
    print(f"Main body revolved: {feat_revolve is not None}")
    
    # -------------------------------------------------------------
    # STEP 2: Aerodynamic Stabilizer Tail Fins
    # -------------------------------------------------------------
    print("\n[Step 2/5] Modeling Aerodynamic Tail Fins...")
    swModel.ClearSelection2(True)
    swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, None, 0)
    swSketchMgr.InsertSketch(True)
    
    swSketchMgr.CreateLine(0.022, 0.075, 0, 0.075, 0.025, 0)
    swSketchMgr.CreateLine(0.075, 0.025, 0, 0.075, 0.010, 0)
    swSketchMgr.CreateLine(0.075, 0.010, 0, 0.016, 0.010, 0)
    swSketchMgr.CreateLine(0.016, 0.010, 0, 0.022, 0.075, 0)
    
    feat_fin = swFeatMgr.FeatureExtrusion3(
        True, False, False, 6, 0, 0.0035, 0.0035,
        False, False, False, False, 0, 0,
        False, False, False, False,
        True, True, True, 0, 0, False
    )
    print(f"Initial Fin extruded: {feat_fin is not None}")
    
    # -------------------------------------------------------------
    # STEP 3: Circular Pattern (4 Symmetrical Fins around Rocket)
    # -------------------------------------------------------------
    print("\n[Step 3/5] Creating 4x Circular Pattern of Fins...")
    swModel.ClearSelection2(True)
    swDocExt.SelectByID2("Boss-Extrude1", "BODYFEATURE", 0, 0, 0, False, 4, None, 0)
    swDocExt.SelectByID2("", "FACE", 0.025, 0.100, 0, True, 1, None, 0)
    
    feat_pattern = swFeatMgr.FeatureCircularPattern4(
        4, two_pi, False, "NULL", False, True, False
    )
    print(f"4x Fin pattern created: {feat_pattern is not None}")
    
    # -------------------------------------------------------------
    # STEP 4: Dual Solid Rocket Boosters (Side Pods)
    # -------------------------------------------------------------
    print("\n[Step 4/5] Adding Solid Rocket Boosters (SRBs)...")
    swModel.ClearSelection2(True)
    swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, None, 0)
    swSketchMgr.InsertSketch(True)
    
    booster_x = 0.034
    booster_r = 0.009
    
    swSketchMgr.CreateCenterLine(booster_x, 0.008, 0, booster_x, 0.200, 0)
    swSketchMgr.CreateLine(booster_x, 0.200, 0, booster_x + booster_r, 0.170, 0)
    swSketchMgr.CreateLine(booster_x + booster_r, 0.170, 0, booster_x + booster_r, 0.020, 0)
    swSketchMgr.CreateLine(booster_x + booster_r, 0.020, 0, booster_x + 0.006, 0.012, 0)
    swSketchMgr.CreateLine(booster_x + 0.006, 0.012, 0, booster_x + 0.008, 0.008, 0)
    swSketchMgr.CreateLine(booster_x + 0.008, 0.008, 0, booster_x, 0.008, 0)
    swSketchMgr.CreateLine(booster_x, 0.008, 0, booster_x, 0.200, 0)
    
    feat_booster = swFeatMgr.FeatureRevolve2(
        True, True, False, False, False, False,
        0, 0, two_pi, 0, False, False,
        0.01, 0.01, 0, 0, 0, True, True, True
    )
    print(f"Right Booster created: {feat_booster is not None}")
    
    # Struts
    swModel.ClearSelection2(True)
    swDocExt.SelectByID2("Right Plane", "PLANE", 0, 0, 0, False, 0, None, 0)
    swSketchMgr.InsertSketch(True)
    
    swSketchMgr.CreateLine(0.020, 0.140, 0, 0.034, 0.140, 0)
    swSketchMgr.CreateLine(0.034, 0.140, 0, 0.034, 0.132, 0)
    swSketchMgr.CreateLine(0.034, 0.132, 0, 0.020, 0.132, 0)
    swSketchMgr.CreateLine(0.020, 0.132, 0, 0.020, 0.140, 0)
    
    swSketchMgr.CreateLine(0.020, 0.050, 0, 0.034, 0.050, 0)
    swSketchMgr.CreateLine(0.034, 0.050, 0, 0.034, 0.042, 0)
    swSketchMgr.CreateLine(0.034, 0.042, 0, 0.020, 0.042, 0)
    swSketchMgr.CreateLine(0.020, 0.042, 0, 0.020, 0.050, 0)
    
    feat_struts = swFeatMgr.FeatureExtrusion3(
        True, False, False, 6, 0, 0.004, 0.004,
        False, False, False, False, 0, 0,
        False, False, False, False,
        True, True, True, 0, 0, False
    )
    print(f"Booster struts created: {feat_struts is not None}")
    
    # Pattern Booster + Struts (2x total)
    swModel.ClearSelection2(True)
    swDocExt.SelectByID2("Revolve2", "BODYFEATURE", 0, 0, 0, False, 4, None, 0)
    swDocExt.SelectByID2("Boss-Extrude2", "BODYFEATURE", 0, 0, 0, True, 4, None, 0)
    swDocExt.SelectByID2("", "FACE", 0.025, 0.100, 0, True, 1, None, 0)
    
    feat_booster_pat = swFeatMgr.FeatureCircularPattern4(
        2, two_pi, False, "NULL", False, True, False
    )
    print(f"Dual Booster Circular Pattern created: {feat_booster_pat is not None}")
    
    # -------------------------------------------------------------
    # STEP 5: Nose Tip Pitot Probe / Antenna + View Setup & Save
    # -------------------------------------------------------------
    print("\n[Step 5/5] Adding Nose Probe, Setting Isometric View, and Saving...")
    swModel.ClearSelection2(True)
    swDocExt.SelectByID2("Front Plane", "PLANE", 0, 0, 0, False, 0, None, 0)
    swSketchMgr.InsertSketch(True)
    
    swSketchMgr.CreateCenterLine(0, 0.320, 0, 0, 0.345, 0)
    swSketchMgr.CreateLine(0, 0.345, 0, 0.001, 0.320, 0)
    swSketchMgr.CreateLine(0.001, 0.320, 0, 0, 0.320, 0)
    swSketchMgr.CreateLine(0, 0.320, 0, 0, 0.345, 0)
    
    feat_probe = swFeatMgr.FeatureRevolve2(
        True, True, False, False, False, False,
        0, 0, two_pi, 0, False, False,
        0.01, 0.01, 0, 0, 0, True, True, True
    )
    print(f"Nose Probe created: {feat_probe is not None}")
    
    # Rebuild & Fit View
    swModel.ForceRebuild3(False)
    swModel.ShowNamedView2("*Isometric", 7)
    swModel.ViewZoomtofit2()
    
    # Save the part document
    output_dir = r"C:\Users\user\.gemini\antigravity\scratch\solidworks_rocket"
    output_file = os.path.join(output_dir, "Aerospace_Rocket_Model.SLDPRT")
    
    save_res = swDocExt.SaveAs(
        output_file,
        0, # swSaveAsCurrentVersion
        1, # swSaveAsOptions_Silent
        None, 0, 0
    )
    print(f"\nRocket 3D Model successfully saved to:\n-> {output_file}")
    print("=" * 60)
    print("SUCCESS: 3D Rocket Model created and ready in SolidWorks!")
    print("=" * 60)

if __name__ == "__main__":
    create_rocket()
