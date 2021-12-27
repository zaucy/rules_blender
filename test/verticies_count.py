import bpy
import sys

expected_vertex_count = 8
total_vertex_count = 0

for ob in bpy.data.objects:
  if type(ob.data) is bpy.types.Mesh:
    total_vertex_count += len(ob.data.vertices)

if total_vertex_count == expected_vertex_count:
  print("Vertex Count is {}. Horray!".format(expected_vertex_count), file=sys.stderr)
  exit(0)
else:
  print("Vertex Count is {}. Boo! Expected {}".format(total_vertex_count, expected_vertex_count), file=sys.stderr)
  exit(1)
