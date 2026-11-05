import bpy
import bmesh
import math

def clear_scene():
    # Delete all mesh and light/camera objects to start clean
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)

def create_material(name, diffuse_color, metallic=0.0, roughness=0.3, emission_color=None, emission_strength=0.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    links = mat.node_tree.links
    
    # Get principled BSDF
    bsdf = nodes.get("Principled BSDF")
    if bsdf:
        # Base Color
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = diffuse_color
        # Metallic
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        # Roughness
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        # Emission
        if emission_color and "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = emission_color
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat

def create_rocket():
    clear_scene()

    # --- Materials ---
    mat_white = create_material("Rocket_Hull", (0.9, 0.92, 0.95, 1.0), metallic=0.1, roughness=0.2)
    mat_red = create_material("Rocket_RedAccent", (0.85, 0.08, 0.08, 1.0), metallic=0.2, roughness=0.25)
    mat_dark = create_material("Rocket_DarkMetal", (0.1, 0.1, 0.12, 1.0), metallic=0.85, roughness=0.3)
    mat_glow_window = create_material("Rocket_WindowGlow", (0.2, 0.8, 1.0, 1.0), metallic=0.1, roughness=0.1, emission_color=(0.1, 0.7, 1.0, 1.0), emission_strength=3.0)
    mat_engine_glow = create_material("Rocket_ThrusterGlow", (1.0, 0.4, 0.05, 1.0), emission_color=(1.0, 0.45, 0.05, 1.0), emission_strength=8.0)

    # --- 1. Main Body (Fuselage) ---
    # Create cylinder for body
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=1.0, depth=3.5, location=(0, 0, 2.5))
    body = bpy.context.active_object
    body.name = "Rocket_Body"
    body.data.materials.append(mat_white)
    
    # Bevel modifier for smoothness
    bev = body.modifiers.new(name="Bevel", type='BEVEL')
    bev.width = 0.04
    bev.segments = 2
    bpy.ops.object.shade_smooth()

    # --- 2. Nose Cone ---
    bpy.ops.mesh.primitive_cone_add(vertices=32, radius1=1.0, radius2=0.0, depth=2.0, location=(0, 0, 5.25))
    nose = bpy.context.active_object
    nose.name = "Rocket_NoseCone"
    nose.data.materials.append(mat_red)
    bpy.ops.object.shade_smooth()

    # --- 3. Cockpit Porthole / Window ---
    # Window Ring Frame
    bpy.ops.mesh.primitive_torus_add(major_radius=0.45, minor_radius=0.08, location=(0, 0.98, 3.2), rotation=(math.radians(90), 0, 0))
    win_ring = bpy.context.active_object
    win_ring.name = "Window_Ring"
    win_ring.data.materials.append(mat_dark)
    bpy.ops.object.shade_smooth()

    # Window Glass
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.42, depth=0.1, location=(0, 0.98, 3.2), rotation=(math.radians(90), 0, 0))
    win_glass = bpy.context.active_object
    win_glass.name = "Window_Glass"
    win_glass.data.materials.append(mat_glow_window)
    bpy.ops.object.shade_smooth()

    # Secondary lower window
    bpy.ops.mesh.primitive_torus_add(major_radius=0.3, minor_radius=0.06, location=(0, 0.98, 2.2), rotation=(math.radians(90), 0, 0))
    win_ring2 = bpy.context.active_object
    win_ring2.name = "Window_Ring2"
    win_ring2.data.materials.append(mat_dark)
    bpy.ops.object.shade_smooth()

    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.28, depth=0.1, location=(0, 0.98, 2.2), rotation=(math.radians(90), 0, 0))
    win_glass2 = bpy.context.active_object
    win_glass2.name = "Window_Glass2"
    win_glass2.data.materials.append(mat_glow_window)
    bpy.ops.object.shade_smooth()

    # --- 4. Rocket Engine Nozzle ---
    bpy.ops.mesh.primitive_cone_add(vertices=32, radius1=0.8, radius2=0.5, depth=0.9, location=(0, 0, 0.3))
    nozzle = bpy.context.active_object
    nozzle.name = "Rocket_Nozzle"
    nozzle.data.materials.append(mat_dark)
    bpy.ops.object.shade_smooth()

    # Thruster Flame / Plasma Core
    bpy.ops.mesh.primitive_cone_add(vertices=32, radius1=0.4, radius2=0.0, depth=1.6, location=(0, 0, -0.7), rotation=(math.radians(180), 0, 0))
    flame = bpy.context.active_object
    flame.name = "Rocket_Exhaust_Flame"
    flame.data.materials.append(mat_engine_glow)
    bpy.ops.object.shade_smooth()

    # --- 5. Aerodynamic Fins (4-way symmetry) ---
    for i in range(4):
        angle = i * (math.pi / 2.0)
        # Create a fin shape using a cube with custom transformation
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, 0))
        fin = bpy.context.active_object
        fin.name = f"Rocket_Fin_{i+1}"
        fin.scale = (0.08, 0.8, 1.2)
        bpy.ops.object.transform_apply(scale=True)
        
        # Taper top of fin using bmesh
        bm = bmesh.new()
        bm.from_mesh(fin.data)
        for v in bm.verts:
            if v.co.z > 0:
                v.co.y += 0.4
                v.co.x *= 0.5
            else:
                v.co.y -= 0.3
        bm.to_mesh(fin.data)
        bm.free()

        # Position and rotate around Z axis
        fin.location = (0, 1.25, 1.3)
        bpy.ops.object.transform_apply(location=False)
        
        # Rotate to cardinal angle
        fin.rotation_euler = (0, 0, angle)
        # Offset according to angle
        fin.location = (
            1.25 * math.sin(angle),
            1.25 * math.cos(angle),
            1.3
        )
        fin.data.materials.append(mat_red)
        bpy.ops.object.shade_smooth()

    # --- 6. Accent Stripe Ring on Body ---
    bpy.ops.mesh.primitive_torus_add(major_radius=1.02, minor_radius=0.05, location=(0, 0, 4.0))
    stripe = bpy.context.active_object
    stripe.name = "Rocket_Stripe"
    stripe.data.materials.append(mat_red)
    bpy.ops.object.shade_smooth()

    # --- 7. Camera and Lighting Setup ---
    # Key Light
    bpy.ops.object.light_add(type='SUN', radius=1.0, location=(5, -5, 8))
    sun = bpy.context.active_object
    sun.name = "Sun_KeyLight"
    sun.data.energy = 4.0
    sun.rotation_euler = (math.radians(45), math.radians(20), math.radians(-35))

    # Fill Light (Cool tint)
    bpy.ops.object.light_add(type='POINT', radius=1.0, location=(-4, 3, 4))
    fill = bpy.context.active_object
    fill.name = "Point_FillLight"
    fill.data.energy = 150.0
    fill.data.color = (0.6, 0.8, 1.0)

    # Rim Light (Warm accent)
    bpy.ops.object.light_add(type='POINT', radius=1.0, location=(3, 4, 1))
    rim = bpy.context.active_object
    rim.name = "Point_RimLight"
    rim.data.energy = 250.0
    rim.data.color = (1.0, 0.5, 0.2)

    # Camera
    bpy.ops.object.camera_add(location=(7.0, -7.0, 4.5), rotation=(math.radians(65), 0, math.radians(45)))
    cam = bpy.context.active_object
    cam.name = "Rocket_Camera"
    bpy.context.scene.camera = cam

    # Use Cycles CPU for headless rendering compatibility
    bpy.context.scene.render.engine = 'CYCLES'
    bpy.context.scene.cycles.device = 'CPU'
    bpy.context.scene.cycles.samples = 32

    # Set render resolution
    bpy.context.scene.render.resolution_x = 1280
    bpy.context.scene.render.resolution_y = 720

    # Save .blend file
    blend_path = r"C:\Users\user\.gemini\antigravity\scratch\rocket.blend"
    bpy.ops.wm.save_as_mainfile(filepath=blend_path)
    print(f"Saved blend file to: {blend_path}")

    try:
        # Render preview image
        render_path = r"C:\Users\user\.gemini\antigravity\scratch\rocket_render.png"
        bpy.context.scene.render.filepath = render_path
        bpy.ops.render.render(write_still=True)
        print(f"Rendered preview image to: {render_path}")
    except Exception as e:
        print(f"Render skipped: {e}")

    print("Rocket model generated successfully.")

if __name__ == "__main__":
    create_rocket()

