import os
import sys
import bpy
import argparse

blender_render_inputs = os.environ["BAZEL_BLENDER_RENDER_INPUTS"]

if not blender_render_inputs:
  sys.exit("Missing environment variable 'BAZEL_BLENDER_RENDER_INPUTS'")

blend_paths = bpy.utils.blend_paths(absolute = True)
inputs = []

with open(blender_render_inputs) as file:
  while (line := file.readline().rstrip()):
    inputs.append(line)
    inputs.append(os.path.abspath(line))

for blend_path in blend_paths:
  if not (blend_path in inputs):
    print(
      "Cannot find '{}'. Make sure '{}' is declared in a blender_library srcs in blender_render deps.".format(
        blend_path,
        os.path.basename(blend_path),
      ),
      file=sys.stdout
    )
    sys.exit(1)
