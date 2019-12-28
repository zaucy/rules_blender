load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

_blender_archives = {
    "2.81": {
        "blender_windows64": struct(
            strip_prefix = "blender-2.81-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-windows64.zip"],
            sha256 = "b350533d23b678d870a3e78a2a0e27e952dc7db49ab801f00025a148dea0d2f5",
        ),
        "blender_linux": struct(
            strip_prefix = "blender-2.81-linux-glibc217-x86_64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-linux-glibc217-x86_64.tar.bz2"],
            sha256 = "e201e7c3dd46aae4a464ec764190199b0ca9ff2e51f9883cd869a4539f33c592",
        ),
        # TODO: Figure out macOS
        # "blender_macos": struct(
        #     urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-macOS.dmg"],
        #     sha256 = "6eb4148e85cf9f610aea1f2366f08a3ae37e5a782d66763ba59aeed99e2971b1",
        # )
    },
}

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

def blender_repositories(blender_version = "2.81"):
    for name in _blender_archives[blender_version]:
        archive = _blender_archives[blender_version][name]
        urls = getattr(archive, "urls")
        sha256 = getattr(archive, "sha256", None)
        strip_prefix = getattr(archive, "strip_prefix", None)
        http_archive(
            name = name,
            urls = urls,
            sha256 = sha256,
            strip_prefix = strip_prefix,
            build_file = "@rules_blender//{}:BUILD.bazel".format(name),
        )

def _zfill(s, n):
    for i in range(1, n + 1):
        s = "0" + s if len(s) < i else s
    return s

def _rel_from(path):
    return "/".join([".." for _ in path.split("/")][:-1])

def _blender_render_impl(ctx):

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
        args.add("--background")
        args.add(ctx.file.blend_file.path)

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

        if ctx.attr.scene:
            args.add("--scene", ctx.attr.scene)

        if batch_frame_start != batch_frame_end:
            args.add("--frame-start", batch_frame_start)
            args.add("--frame-end", batch_frame_end)
            args.add("--render-anim")
        else:
            args.add("--render-frame", batch_frame_start)

        ctx.actions.run(
            executable = ctx.executable.blender_executable_,
            arguments = [args],
            inputs = [ctx.file.blend_file],
            outputs = batch_outputs,
            mnemonic = "BlenderRenderBatch{}".format(batch_num),
            progress_message = "Rendering '{}' frames {} to {}".format(
                ctx.file.blend_file.path,
                batch_frame_start,
                batch_frame_end,
            ),
        )

        outputs.extend(batch_outputs)

    return DefaultInfo(
        files = depset(outputs),
    )

_blender_render = rule(
    implementation = _blender_render_impl,
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
        "blender_executable_": attr.label(
            mandatory = True,
            executable = True,
            allow_single_file = True,
            cfg = "host",
        ),
    },
)

def blender_render(blender_executable_ = None, **kwargs):

    # Cannot 'select' default value of attr so we need to expose this attr but
    # still prevent the user from using it.
    # See issue: https://github.com/bazelbuild/bazel/issues/1698
    if blender_executable_ != None:
        fail("Cannot set internal attribute 'blender_executable_' of the 'blender_render' rule")

    _blender_render(
        blender_executable_ = select({
            "@bazel_tools//src/conditions:host_windows": "@blender_windows64//:blender",
            "@bazel_tools//src/conditions:host_windows_msvc": "@blender_windows64//:blender",
            "@bazel_tools//src/conditions:host_windows_msys": "@blender_windows64//:blender",
            "@bazel_tools//src/conditions:linux_x86_64": "@blender_linux//:blender",
        }),
        **kwargs
    )
