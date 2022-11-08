"""Exports various blender rules
"""

_render_format_extensions = {
    "TGA": "",
    "RAWTGA": "",
    "JPEG": ".jpg",
    "IRIS": "",
    "IRIZ": "",
    "AVIRAW": ".avi",
    "AVIJPEG": ".avi",
    "PNG": ".png",
    "BMP": ".bmp",
    "WEBM": ".webm",
}

# https://docs.blender.org/manual/en/latest/files/media/image_formats.html#image-formats
_allowed_image_formats = [
    ".bmp",
    ".sgi",
    ".rgb",
    ".bw",
    ".png",
    ".jpg",
    ".jpeg",
    ".jp2",
    ".jp2",
    ".j2c",
    ".tga",
    ".cin",
    ".dpx",
    ".exr",
    ".hdr",
    ".tif",
    ".tiff",
]

def _zfill(s, n):
    for i in range(1, n + 1):
        s = "0" + s if len(s) < i else s
    return s

BlenderLibraryInfo = provider(
    "Separate blender sources used by blender_render as a dependency",
    fields = ["srcs"],
)

def is_video_render_format(format):
    return format == "WEBM"

def _blender_render(ctx):
    outputs = []
    frame_start = ctx.attr.frame_start
    frame_end = ctx.attr.frame_end
    batch_render = ctx.attr.batch_render
    outext = _render_format_extensions[ctx.attr.render_format]

    is_video = is_video_render_format(ctx.attr.render_format)

    if frame_start > frame_end:
        fail("frame_start must be <= frame_end")

    if batch_render == 0:
        batch_render = (frame_end+1) - frame_start

    batch_count = ((frame_end+1) - frame_start) // batch_render
    if ((frame_end+1) - frame_start) % batch_render > 0:
        batch_count += 1

    inputs = [ctx.file.blend_file]

    for dep in ctx.attr.deps:
        inputs.extend(dep[BlenderLibraryInfo].srcs)

    for python_script in ctx.files.python_scripts:
        inputs.append(python_script)

    for batch_num in range(0, batch_count):
        batch_frame_start = frame_start + (batch_num * batch_render)
        batch_frame_end = batch_frame_start + batch_render - 1
        batch_outputs = []

        if batch_frame_end > frame_end:
            batch_frame_end = frame_end

        args = ctx.actions.args()
        args.add(ctx.file.blend_file)

        if ctx.attr.scene:
            args.add("-S", ctx.attr.scene)

        args.add("-P", ctx.file.enable_cycles_devices_script)

        for python_script in ctx.files.python_scripts:
            args.add("-P", python_script)

        if batch_frame_start != batch_frame_end:
            args.add("-s", batch_frame_start)
            args.add("-e", batch_frame_end)

        rendering_single_frame = batch_count == 1 and frame_start == frame_end
        
        if rendering_single_frame or is_video:
                outfilename = ctx.attr.name + outext
                outfile = ctx.actions.declare_file(outfilename)
                batch_outputs.append(outfile)
        else:
            for frame_num in range(batch_frame_start, batch_frame_end + 1):
                frame_str = str(frame_num)
                if len(frame_str) > 4:
                    fail("Does not support frames > 9999")
                frame_str = _zfill(frame_str, 4)

                outfilename = ctx.attr.name + frame_str + outext
                outfile = ctx.actions.declare_file(outfilename)
                batch_outputs.append(outfile)

        if rendering_single_frame or is_video:
            args.add("-o", batch_outputs[0])
            args.add("-x", "0")
        else:
            args.add("-o", batch_outputs[0].dirname + "/" + ctx.attr.name + "####" + outext)
            args.add("-x", "1")

        if ctx.attr.render_engine != "UNSET":
            args.add("-E", ctx.attr.render_engine)

        if rendering_single_frame and is_video:
            fail("Cannot use video render format (e.g. {}) for single frame. Please set frame_start and frame_end when using a video format.".format(ctx.attr.render_format))

        args.add("-F", ctx.attr.render_format)

        if batch_frame_start != batch_frame_end:
            args.add("-s", batch_frame_start)
            args.add("-e", batch_frame_end)
            args.add("-a")
        else:
            args.add("-f", batch_frame_start)

        for view_layer in ctx.attr.view_layers:
            args.add("--view_layer", view_layer)

        if len(ctx.attr.python_script_args) > 0:
            args.add("--")
            args.add_all(ctx.attr.python_script_args)

        progress_message = "Rendering '{}'".format(ctx.file.blend_file.path)

        if ctx.attr.scene:
            progress_message += " scene '{}'".format(ctx.attr.scene)

        if batch_frame_start != batch_frame_end:
            progress_message += " frames {} to {}".format(
                batch_frame_start,
                batch_frame_end,
            )
        else:
            progress_message += " frame {}".format(batch_frame_start)
        
        has_python_scripts = len(ctx.files.python_scripts) > 0

        if has_python_scripts:
            progress_message += " ("
            for python_script in ctx.files.python_scripts:
                progress_message += "{}, ".format(python_script.basename)
            # remove trailing ", "
            progress_message = progress_message[:-2] + ")"

        args_file = ctx.actions.declare_file("{}_args_file_batch_{}".format(ctx.label.name, batch_num))
        ctx.actions.write(args_file, args)
        inputs.append(args_file)

        worker_args = ctx.actions.args()
        worker_args.add("--log-level", "0")
        worker_args.add("--background")
        worker_args.add("--factory-startup")
        worker_args.add("-noaudio")
        worker_args.add("--enable-autoexec")
        worker_args.add("-P", ctx.file._bazel_blender_render_worker)
        worker_args.add("--")
        worker_args.add("--worker")

        ctx.actions.run(
            executable = ctx.executable.blender_executable,
            arguments = [worker_args, "@%s" % args_file.path],
            inputs = inputs,
            outputs = batch_outputs,
            mnemonic = "BlenderRender",
            progress_message = progress_message,
            execution_requirements = {
                "supports-workers" : "1",
                "supports-multiplex-workers": "1",
                "supports-worker-cancellation": "1",
                "requires-worker-protocol" : "json",
                "worker-key-mnemonic": "BlenderRender",
            },
        )

        outputs.extend(batch_outputs)

    return DefaultInfo(
        files = depset(outputs),
    )

blender_render = rule(
    implementation = _blender_render,
    doc = "Render a .blend file in to a list of frames",
    attrs = {
        "blend_file": attr.label(
            doc = "Blend file to render",
            allow_single_file = True,
            mandatory = True,
        ),
        "batch_render": attr.int(
            doc = "Number of frames to render at a time. If `0` all the frames will be rendered at once.",
        ),
        "render_engine": attr.string(
            doc = "Render engine to use. If `\"UNSET\"` then the render engine set in the blend file is used.",
            default = "UNSET",
            values = [
                "UNSET",
                "BLENDER_EEVEE",
                "BLENDER_WORKBENCH",
                "CYCLES",
            ],
        ),
        "render_format": attr.string(
            doc = "Render format. [See blender documentation](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html#format-options)",
            mandatory = True,
            values = [
                "TGA",
                "RAWTGA",
                "JPEG",
                "IRIS",
                "IRIZ",
                "AVIRAW",
                "AVIJPEG",
                "PNG",
                "BMP",
                "WEBM",
            ],
        ),
        "scene": attr.string(
            doc = "Scene to render. If not set the default scene in the blend file is used.",
        ),
        "frame_start": attr.int(
            doc = "Start frame in animation",
            default = 0,
        ),
        "frame_end": attr.int(
            doc = "End frame in animation",
            default = 0,
        ),
        "python_scripts": attr.label_list(
            doc = "Python scripts to run right before render begins",
            mandatory = False,
            allow_files = [".py"],
        ),
        "python_script_args": attr.string_list(
            doc = "Arguments to pass to blender after '--'. Typically handled by the script the `python_script` attribute."
        ),
        "deps": attr.label_list(
            doc = "`blender_library` dependencies",
            default = [],
            allow_empty = True,
            mandatory = False,
            providers = [BlenderLibraryInfo],
        ),
        "blender_executable": attr.label(
            doc = "Blender executable to use for the render.",
            default = Label("@blender//:blender"),
            executable = True,
            cfg = "exec",
        ),
        "_bazel_blender_render_worker": attr.label(
            default = Label("@rules_blender//rules_blender_scripts:bazel_blender_render_worker.py"),
            allow_single_file = True,
        ),
        "enable_cycles_devices_script": attr.label(
            default = Label("@blender//:enable_cycles_devices.py"),
            allow_single_file = True,
        ),
        "view_layers": attr.string_list(
            default = [],
            allow_empty = True,
        ),
    },
)

def _blender_library(ctx):
    return [BlenderLibraryInfo(srcs = ctx.files.srcs)]

blender_library = rule(
    implementation = _blender_library,
    doc = "Group .blend files and images together to be used as `deps` in `blender_render`.",
    attrs = {
        "srcs": attr.label_list(
            doc = "List of blend files and image files",
            mandatory = True,
            allow_files = [".blend"] + _allowed_image_formats,
        ),
    },
)

def _blender_script(ctx):
    args = ctx.actions.args()
    args.add("--log-level", "0")
    args.add("--background")
    args.add("-noaudio")
    args.add("--factory-startup")

    args.add(ctx.file.blend_file)

    if ctx.attr.scene:
        args.add("--scene", ctx.attr.scene)

    args.add("--python", ctx.file.python_script)

    if ctx.attr.autoexec_scripts:
        args.add("--enable-autoexec")
    else:
        args.add("--disable-autoexec")

    args.add("--")
    for out in ctx.outputs.outs:
        args.add("-o", out.path)

    args.add_all(ctx.attr.python_script_args)

    ctx.actions.run(
        executable = ctx.executable.blender_executable,
        arguments = [args, "--quiet"],
        inputs = [ctx.file.blend_file, ctx.file.python_script],
        outputs = ctx.outputs.outs,
        mnemonic = "BlenderScript",
    )

    return DefaultInfo(files = depset(ctx.outputs.outs))

blender_script = rule(
    implementation = _blender_script,
    doc = "Run a python script in blender on a specific blend file to get an output",
    attrs = {
        "blend_file": attr.label(
            doc = "Blend file to run the script on",
            allow_single_file = True,
            mandatory = True,
        ),
        "scene": attr.string(
            doc = "Scene to set before running python script (optional)",
            mandatory = False,
        ),
        "python_script": attr.label(
            doc = "Python script to run",
            mandatory = False,
            allow_single_file = [".py"],
        ),
        "python_script_args": attr.string_list(
            doc = "Arguments to pass to blender after '--' and the built in -o arguments"
        ),
        "autoexec_scripts": attr.bool(
            doc = "Enable automatic Python script execution",
            default = False,
        ),
        "outs": attr.output_list(
            allow_empty = False,
            doc = "Output files the python_script writes to. These get passed to in format -o path/to/output/file",
            mandatory = True,
        ),
        "blender_executable": attr.label(
            doc = "Blender executable to use",
            default = Label("@blender//:blender"),
            executable = True,
            cfg = "exec",
        ),
    },
)

_hybrid_script_template = """
:; # --- begin runfiles.bash initialization v2 ---
:; # Copy-pasted from the Bazel Bash runfiles library v2.
:; set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
:; source "${{RUNFILES_DIR:-/dev/null}}/$f" 2>/dev/null || source "$(grep -sm1 "^$f " "${{RUNFILES_MANIFEST_FILE:-/dev/null}}" | cut -f2- -d' ')" 2>/dev/null || source "$0.runfiles/$f" 2>/dev/null || source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || {{ echo>&2 "ERROR: cannot find $f"; exit 1; }}; f=; set -e
:; # --- end runfiles.bash initialization v2 ---
:; $(rlocation blender/blender) {args} "$@"
:; exit
@echo off

set "BLENDER_WRAPPER="
set "MANIFEST_FILE=%CD%\\..\\MANIFEST"

for /F "usebackq tokens=*" %%a in (%MANIFEST_FILE%) do (
    for /F "tokens=1,2" %%b in ("%%a") do (
        if %%b=="blender/blender_wrapper.cmd" do (
            set BLENDER_WRAPPER=%%c
            goto found_blender_wrapper
        )
    )
)

:found_blender_wrapper

"%BLENDER_WRAPPER%" {args} %*
"""

def _path_to_str(path):
    if path.dirname:
        return path.dirname + "/" + path.basename
    else:
        return path.basename

def _blender_test(ctx):
    args = []

    args += ["--log-level", "0"]
    args.append("--background")
    args.append("-noaudio")
    args.append("--factory-startup")

    args.append(_path_to_str(ctx.file.blend_file))

    if ctx.attr.scene:
        args += ["--scene", ctx.attr.scene]

    args += ["--python", _path_to_str(ctx.file.python_script)]

    if ctx.attr.autoexec_scripts:
        args.append("--enable-autoexec")
    else:
        args.append("--disable-autoexec")

    args.append("--")

    args += ctx.attr.python_script_args

    args.append("--quiet")

    test_script = ctx.actions.declare_file(ctx.label.name + ".cmd")
    ctx.actions.write(
        test_script,
        _hybrid_script_template.format(args = " ".join(args)),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.data + [
        ctx.executable.blender_executable,
        ctx.file.blend_file,
        ctx.file.python_script,
    ])
    runfiles = runfiles.merge(ctx.attr._bash_runfiles[DefaultInfo].default_runfiles)
    runfiles = runfiles.merge(ctx.attr.blender_executable[DefaultInfo].default_runfiles)

    return DefaultInfo(
        executable = test_script,
        runfiles = runfiles,
    )

blender_test = rule(
    implementation = _blender_test,
    test = True,
    doc = "Run a python script in blender on a specific blend file as a test",
    attrs = {
        "blend_file": attr.label(
            doc = "Blend file to run the script on",
            allow_single_file = True,
            mandatory = True,
        ),
        "scene": attr.string(
            doc = "Scene to set before running python script (optional)",
            mandatory = False,
        ),
        "python_script": attr.label(
            doc = "Python script to run",
            mandatory = False,
            allow_single_file = [".py"],
        ),
        "python_script_args": attr.string_list(
            doc = "Arguments to pass to blender after '--'"
        ),
        "autoexec_scripts": attr.bool(
            doc = "Enable automatic Python script execution",
            default = False,
        ),
        "data": attr.label_list(),
        "blender_executable": attr.label(
            doc = "Blender executable to use",
            default = Label("@blender//:blender"),
            executable = True,
            cfg = "exec",
        ),
        "_bash_runfiles": attr.label(
            default = Label("@bazel_tools//tools/bash/runfiles"),
        ),
    },
)
