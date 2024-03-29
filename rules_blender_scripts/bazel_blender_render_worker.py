import bpy
import sys
import json
import os
import argparse
import traceback
import builtins

startup_blend_file = bpy.data.filepath
current_request = None
current_response = None

def debug_log(msg):
  if current_request is not None and current_request.verbosity > 0:
    print(msg)

def handle_except(type, value, _):
  if current_response is not None:
    current_response.output = value
    current_response.write()
  traceback.print_last(file=sys.stdout)

sys.excepthook = handle_except

base_argv_start_index = sys.argv.index('--')
base_argv = sys.argv[:base_argv_start_index]

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
parser.add_argument("-a", dest="render_anim", default=False, action="store_true")
parser.add_argument("-E", metavar="engine", dest="engine")
parser.add_argument("-F", metavar="format", dest="render_format", choices=['TGA', 'RAWTGA', 'JPEG', 'IRIS', 'IRIZ', 'AVIRAW', 'AVIJPEG', 'PNG', 'BMP', 'WEBM'])
parser.add_argument("-S", metavar="ExampleScene", dest="scene")
parser.add_argument("--view_layer", action='append', dest="view_layers")

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

    if "inputs" in work_request_json:
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
    debug_log("Writing work response: %s" % response_json)
    print(response_json, file=sys.stderr)

def execfile(filepath, args):
  import os
  global_namespace = {
    "__file__": filepath,
    "__name__": "__main__",
    "rules_blender_python_script_args": args,
  }
  with open(filepath, 'rb') as file:
    # importing builtins because blender re.compile gets conflicted here
    exec(builtins.compile(file.read(), filepath, 'exec'), global_namespace)

def handle_work_request():
  if current_request.cancel:
    current_response.was_cancelled = True
    current_response.write()
    debug_log("Quitting due to cancel request")
    bpy.ops.wm.quit_blender()
    return

  extra_args = []

  try:
    extra_args_start_index = current_request.arguments.index('--')
    args = parser.parse_args(current_request.arguments[:extra_args_start_index])
    extra_args = current_request.arguments[extra_args_start_index+1:]
  except ValueError:
    args = parser.parse_args(current_request.arguments)

  debug_log("Opening blend file %s" % args.blend_file)
  bpy.ops.wm.open_mainfile(filepath=args.blend_file, use_scripts=True)
  debug_log("After opening %s" % args.blend_file)

  sys.argv = base_argv.copy()
  sys.argv.append(args.blend_file)
  sys.argv.append('--')
  sys.argv.extend(extra_args)

  if args.scene:
    bpy.context.window.scene = bpy.data.scenes[args.scene]

  if args.render_format:
    if args.render_format == "WEBM":
      bpy.context.scene.render.image_settings.file_format = "FFMPEG"
      bpy.context.scene.render.image_settings.color_mode = 'RGBA'
      bpy.context.scene.render.ffmpeg.format = 'WEBM'
      bpy.context.scene.render.ffmpeg.codec = 'WEBM'
      bpy.context.scene.render.ffmpeg.constant_rate_factor = 'PERC_LOSSLESS'
    else:
      bpy.context.scene.render.image_settings.file_format = args.render_format

  if args.render_frame is not None:
    bpy.context.scene.frame_start = args.render_frame
    bpy.context.scene.frame_end = args.render_frame
    bpy.context.scene.frame_set(args.render_frame)

  if args.frame_start is not None:
    bpy.context.scene.frame_start = args.frame_start

  if args.frame_end is not None:
    bpy.context.scene.frame_end = args.frame_end

  if args.render_output:
    args.render_output = args.render_output.strip('\'\"')
    bpy.context.scene.render.filepath = os.path.abspath(args.render_output)

  for python_script in args.python_scripts:
    debug_log("Executing python script: %s" % python_script)
    execfile(python_script, extra_args)

  if args.use_extension:
    bpy.context.scene.render.use_file_extension = True
  else:
    bpy.context.scene.render.use_file_extension = False

  if bool(args.view_layers):
    for view_layer in bpy.context.scene.view_layers:
      print(view_layer)
      view_layer.use = False
    for view_layer_name in args.view_layers:
      if not view_layer_name in bpy.context.scene.view_layers:
        current_response.output = "Unknown view layer '{}'".format(
          view_layer_name,
        )
        current_response.write()
        return;
      bpy.context.scene.view_layers[view_layer_name].use = True

  # Request inputs may be 0 for a one shot. In that case we'll skip the inputs
  # validation. This may need to be changed in the future.
  if len(current_request.inputs) > 0:
    for blend_path in bpy.utils.blend_paths():
      blend_path = os.path.abspath(bpy.path.abspath(blend_path))
      found_input = False
      for req_input in current_request.inputs:
        req_input_path = os.path.abspath(req_input.path)
        if req_input_path == blend_path:
          found_input = True
          break
      if not found_input and os.path.basename(blend_path) == 'copybuffer.blend':
        # current_response.output = "[WARNING] 'copybuffer.blend' reference"
        # current_response.write()
        pass
      elif not found_input:
        current_response.output = "Cannot find '{}'. Make sure '{}' is declared in a blender_library srcs in blender_render deps.".format(
          blend_path,
          os.path.basename(blend_path),
        )
        current_response.output += "\nChecked these paths:\n"
        for req_input in current_request.inputs:
          req_input_path = os.path.abspath(req_input.path)
          current_response.output += " - " + req_input_path + "\n"
        current_response.write()
        return

  debug_log("Render start...")
  bpy.ops.render.render(
    animation = args.render_anim,
    write_still = not args.render_anim,
  )

  debug_log("Render end...")

def wait_for_work_request():
  global current_request
  global current_response
  
  debug_log("Opening empty blend file before waiting for work request...")
  bpy.ops.wm.read_homefile(use_empty=True, use_factory_startup=True)
  debug_log("Waiting for work request...")
  current_request = BazelWorkRequest(json.loads(sys.stdin.readline()))
  debug_log("Received work request (id=%s)" % current_request.request_id)
  current_response = BazelWorkResponse(current_request)
  try:
    handle_work_request()
  except Exception as err:
    current_response.output = traceback.format_exc()
    current_response.write()

persistent_worker = False
one_shot_args = []
for arg in sys.argv:
  if arg == "--persistent_worker":
    persistent_worker = True
  if arg.startswith("@"):
    one_shot_args = open(arg[1:]).read().splitlines()

@bpy.app.handlers.persistent
def render_complete_handler(unused0, unused1):
  debug_log("Render Complete!")
  current_response.write()
  if persistent_worker:
    wait_for_work_request()
  else:
    debug_log("One shot done")
    bpy.ops.wm.quit_blender()

bpy.app.handlers.render_complete.append(render_complete_handler)

# https://docs.bazel.build/versions/main/persistent-workers.html
if persistent_worker:
  wait_for_work_request()
else:
  current_request = BazelWorkRequest({
    "arguments": one_shot_args,
    "requestId": 0,
    "cancel": False,
    "verbosity": 0,
    "inputs": [],
  })
  debug_log("Doing one shot request...")
  current_response = BazelWorkResponse(current_request)
  handle_work_request()
