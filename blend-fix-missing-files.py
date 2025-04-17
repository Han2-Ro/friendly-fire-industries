import bpy
import os

# Set the top-level directory containing all subfolders
top_dir = "scenes/levels"  # <-- change this

# Set the path Blender should use to find missing files
search_dir = "/home/hannes/projects/godot/brackeys-game-jam/assets/textures/"  # <-- change this

# Save original file to restore later
original_file = bpy.data.filepath

for root, dirs, files in os.walk(top_dir):
    for file in files:
        if file.endswith(".blend"):
            filepath = os.path.join(root, file)
            print(f"\n--- Checking: {filepath} ---")

            # Open the .blend file
            bpy.ops.wm.open_mainfile(filepath=filepath)

            # Try to find missing files in the specified search directory
            bpy.ops.file.find_missing_files(directory=search_dir)

            # Check for missing images
            missing = False
            for img in bpy.data.images:
                if img.source == 'FILE':
                    img_path = bpy.path.abspath(img.filepath)
                    if not os.path.exists(img_path):
                        print(f"  MISSING: {img_path}")
                        missing = True

            if not missing:
                print("  ✅ All external images found.")
                bpy.ops.wm.save_mainfile()

# Optionally reopen original file (so Blender doesn’t stay on last opened .blend)
if original_file:
    bpy.ops.wm.open_mainfile(filepath=original_file)
