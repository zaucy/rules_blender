import bpy
import sys
import json
import os
import argparse

def handle_except(type, value, traceback):
  print("[%s] %s" % (type, value))

sys.excepthook = handle_except

parser = argparse.ArgumentParser(
  prog = "bazel_blender_render_worker.py",
  description = "rules_blender mock blender arguments for worker",
)
parser.add_argument("blend_file", type=str)
parser.add_argument("-P", metavar="example.py", type=str, dest="python_scripts", action="append") # python script
parser.add_argument("-o", metavar="example-######.png", type=str, dest="render_output") #output
parser.add_argument("-x", type=bool, dest="use_extension")
parser.add_argument("-f", type=int, dest="render_frame")
parser.add_argument("-s", type=int, dest="frame_start")
parser.add_argument("-e", type=int, dest="frame_end")
parser.add_argument("-a", type=bool, dest="render_anim", default=False)
parser.add_argument("-E", metavar="engine", dest="engine")
parser.add_argument("-F", metavar="format", dest="render_format", choices=['TGA', 'RAWTGA', 'JPEG', 'IRIS', 'IRIZ', 'AVIRAW', 'AVIJPEG', 'PNG', 'BMP'])
parser.add_argument("-S", metavar="ExampleScene", dest="scene")

current_request = None
current_response = None

class BazelWorkInput:
  def __init__(self, work_request_input_json):
    self.path = work_request_input_json["path"]
    self.digest = work_request_input_json["digest"]

class BazelWorkRequest:
  def __init__(self, work_request_json):
    self.inputs = []
    self.request_id = 0
    self.cancel = False
    self.verbosity = 0

    if "arguments" in work_request_json:
      self.arguments = work_request_json["arguments"]

    if "inputs" in work_request_json["inputs"]:
      for input_json in work_request_json["inputs"]:
        self.inputs.append(BazelWorkInput(input_json))

    if "requestId" in work_request_json:
      self.request_id = work_request_json["requestId"]

    if "cancel" in work_request_json:
      self.cancel = work_request_json["cancel"]

    if "verbosity" in work_request_json:
      self.verbosity = work_request_json["verbosity"]

class BazelWorkResponse:
  def __init__(self, request):
    self.exit_code = 0
    self.output = ""
    self.request_id = request.request_id
    self.was_cancelled = False

  def write(self):
    response_json = json.dumps({
      "exitCode": self.exit_code,
      "output": self.output,
      "requestId": self.request_id,
      "wasCancelled": self.was_cancelled,
    })
    print("Writing work response: %s" % response_json)
    print(response_json, file=sys.stderr)

def execfile(filepath):
  import os
  global_namespace = {
    "__file__": filepath,
    "__name__": "__main__",
  }
  with open(filepath, 'rb') as file:
    exec(compile(file.read(), filepath, 'exec'), global_namespace)

def handle_work_request():
  if current_request.cancel:
    current_response.was_cancelled = True
    current_response.write()
    print("Quitting due to cancel request")
    bpy.ops.wm.quit_blender()
    return

  args = parser.parse_args(current_request.arguments)

  print("Opening blend file %s" % args.blend_file)
  bpy.ops.wm.open_mainfile(filepath=args.blend_file)
  print("After opening %s" % args.blend_file)

  for python_script in args.python_scripts:
    print("Executing python script: %s" % python_script)
    execfile(python_script)

  if args.scene:
    bpy.context.screen.scene=bpy.data.scenes[args.scene]

  if args.render_output:
    bpy.context.scene.render.filepath = os.path.abspath(args.render_output)

  # Response will be written
  print("Render start...")
  bpy.ops.render.render(animation = args.render_anim)
  print("Render end...")

def wait_for_work_request():
  global current_request
  global current_response

  print("Waiting for work request...")
  current_request = BazelWorkRequest(json.loads(sys.stdin.readline()))
  print("Received work request (id=%s)" % current_request.request_id)
  current_response = BazelWorkResponse(current_request)
  handle_work_request()

persistent_worker = False
one_shot_args = []
for arg in sys.argv:
  if arg == "--persistent_worker":
    persistent_worker = True
  if arg.startswith("@"):
    one_shot_args = open(arg[1:]).read().splitlines()

@bpy.app.handlers.persistent
def render_complete_handler(unused0, unused1):
  print("Render Complete!")
  current_response.write()
  if persistent_worker:
    wait_for_work_request()
  else:
    print("One shot done")
    bpy.ops.wm.quit_blender()

bpy.app.handlers.render_complete.append(render_complete_handler)

# https://docs.bazel.build/versions/main/persistent-workers.html
if persistent_worker:
  wait_for_work_request()
else:
  print("Doing one shot request...")
  current_request = BazelWorkRequest({
    "arguments": one_shot_args,
    "requestId": 0,
    "cancel": False,
    "verbosity": 0,
    "inputs": [],
  })
  current_response = BazelWorkResponse(current_request)
  handle_work_request()
