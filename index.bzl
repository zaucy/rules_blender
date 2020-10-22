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
}

def _zfill(s, n):
    for i in range(1, n + 1):
        s = "0" + s if len(s) < i else s
    return s

def _rel_from(path):
    return "/".join([".." for _ in path.split("/")][:-1])

BlenderLibraryInfo = provider()

def _blender_render(ctx):
    outputs = []
    render_format = ctx.attr.render_format
    frame_start = ctx.attr.frame_start
    frame_end = ctx.attr.frame_end
    batch_render = ctx.attr.batch_render
    outext = _render_format_extensions[ctx.attr.render_format]

    if batch_render == 0:
        batch_render = (frame_end+1) - frame_start

    batch_count = ((frame_end+1) - frame_start) // batch_render
    if ((frame_end+1) - frame_start) % batch_render > 0:
        batch_count += 1

    build_file_dir = ctx.build_file_path.rstrip("BUILD").rstrip("BUILD.bazel")
    root_out_dir = _rel_from(ctx.file.blend_file.path) + "/" + ctx.bin_dir.path + "/" + build_file_dir

    for batch_num in range(0, batch_count):
        inputs = [ctx.file.blend_file]
        batch_frame_start = frame_start + (batch_num * batch_render)
        batch_frame_end = batch_frame_start + batch_render - 1
        batch_outputs = []

        if batch_frame_end > frame_end:
            batch_frame_end = frame_end

        args = ctx.actions.args()
        args.add("--log-level", "0")
        args.add("--background")
        args.add(ctx.file.blend_file.path)

        for dep in ctx.attr.deps:
            inputs.extend(dep[BlenderLibraryInfo].blend_files)

        if ctx.attr.scene:
            args.add("--scene", ctx.attr.scene)

        if ctx.file.python_script:
            args.add("--python", ctx.file.python_script)
            inputs.append(ctx.file.python_script)

        if batch_frame_start != batch_frame_end:
            args.add("--frame-start", batch_frame_start)
            args.add("--frame-end", batch_frame_end)

        args.add("-o", "//" + root_out_dir + ctx.attr.name + "####" + outext)
        for frame_num in range(batch_frame_start, batch_frame_end + 1):
            frame_str = str(frame_num)
            if len(frame_str) > 4:
                fail("Does not support frames > 9999")
            frame_str = _zfill(frame_str, 4)

            outfilename = ctx.attr.name + frame_str + outext
            outfile = ctx.actions.declare_file(outfilename)
            batch_outputs.append(outfile)

        args.add("-x", "1")

        if ctx.attr.render_engine != "UNSET":
            args.add("--engine", ctx.attr.render_engine)

        args.add("--render-format", ctx.attr.render_format)

        if batch_frame_start != batch_frame_end:
            args.add("--frame-start", batch_frame_start)
            args.add("--frame-end", batch_frame_end)
            args.add("--render-anim")
        else:
            args.add("--render-frame", batch_frame_start)

        if ctx.attr.autoexec_scripts:
            args.add("--enable-autoexec")
        else:
            args.add("--disable-autoexec")

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

        if ctx.file.python_script:
            progress_message += " ({})".format(ctx.file.python_script.basename)

        ctx.actions.run(
            executable = ctx.executable.blender_executable,
            arguments = [args, "--quiet"],
            inputs = inputs,
            outputs = batch_outputs,
            mnemonic = "BlenderRenderBatch{}".format(batch_num),
            progress_message = progress_message,
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
            ],
        ),
        "scene": attr.string(
            doc = "Scene to render. If not set the default scene in the blend file is used.",
        ),
        "frame_start": attr.int(
            doc = "Start frame in animation",
            mandatory = True,
        ),
        "frame_end": attr.int(
            doc = "End frame in animation",
            mandatory = True,
        ),
        "autoexec_scripts": attr.bool(
            doc = "Enable automatic Python script execution",
            default = False,
        ),
        "python_script": attr.label(
            doc = "Python script to run right before render begins",
            mandatory = False,
            allow_single_file = [".py"],
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
            cfg = "host",
        ),
    },
)

def _blender_library(ctx):
    return [BlenderLibraryInfo(blend_files = ctx.files.srcs)]

blender_library = rule(
    implementation = _blender_library,
    doc = "Group .blend files together to be used as `deps` in `blender_render`. Usually used when the .blend files in `srcs` are linked to a .blend file in `blender_render`.",
    attrs = {
        "srcs": attr.label_list(
            doc = "List of blend files",
            mandatory = True,
            allow_files = [".blend"],
        ),
    },
)
