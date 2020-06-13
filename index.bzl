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
        batch_frame_start = frame_start + (batch_num * batch_render)
        batch_frame_end = batch_frame_start + batch_render - 1
        batch_outputs = []

        if batch_frame_end > frame_end:
            batch_frame_end = frame_end

        args = ctx.actions.args()
        args.add("--log-level", "0")
        args.add("--background")
        args.add(ctx.file.blend_file.path)

        if ctx.attr.scene:
            args.add("--scene", ctx.attr.scene)

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

        ctx.actions.run(
            executable = ctx.executable.blender_executable,
            arguments = [args],
            inputs = [ctx.file.blend_file],
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
    attrs = {
        "blend_file": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
        "batch_render": attr.int(),
        "render_engine": attr.string(
            default = "UNSET",
            values = [
                "UNSET",
                "BLENDER_EEVEE",
                "BLENDER_WORKBENCH",
                "CYCLES",
            ],
        ),
        "render_format": attr.string(
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
        "scene": attr.string(),
        "frame_start": attr.int(mandatory = True),
        "frame_end": attr.int(mandatory = True),
        "blender_executable": attr.label(
            default = Label("@blender//:blender"),
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
    },
)
