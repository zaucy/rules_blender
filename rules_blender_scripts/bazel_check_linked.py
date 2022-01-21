import os
import sys
import bpy
import argparse

blender_render_inputs = os.environ["BAZEL_BLENDER_RENDER_INPUTS"]

if not blender_render_inputs:
  sys.exit("Missing environment variable 'BAZEL_BLENDER_RENDER_INPUTS'")

blend_paths = bpy.utils.blend_paths(absolute = False)
inputs = []

with open(blender_render_inputs) as file:
  while (line := file.readline().rstrip()):
    inputs.append(line)
    inputs.append(os.path.abspath(line))

for blend_path in blend_paths:
  blend_path = bpy.path.abspath(blend_path)
  found_input = False
  for input_path in inputs:
    if os.path.samefile(input_path, blend_path):
      found_input = True
      break
  if not found_input:
    print("Cannot find '{}'. Make sure '{}' is declared in a blender_library srcs in blender_render deps.".format(
      blend_path,
      os.path.basename(blend_path),
    ))
    sys.exit(1)
