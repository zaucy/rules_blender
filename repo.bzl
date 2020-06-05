_windows_build_file_content = """
exports_files(["blender.exe"])

alias(
    name = "blender",
    actual = ":blender.exe",
    visibility = ["//visibility:public"],
)
"""

_build_file_content = """
exports_files(["blender"], visibility = ["//visibility:public"])
"""

_known_blender_archives = {
    "2.81": {
        "windows64": struct(
            strip_prefix = "blender-2.81-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-windows64.zip"],
            sha256 = "b350533d23b678d870a3e78a2a0e27e952dc7db49ab801f00025a148dea0d2f5",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.81-linux-glibc217-x86_64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-linux-glibc217-x86_64.tar.bz2"],
            sha256 = "e201e7c3dd46aae4a464ec764190199b0ca9ff2e51f9883cd869a4539f33c592",
            build_file_content = _build_file_content,
        ),
    },
    "2.81a": {
        "windows64": struct(
            strip_prefix = "blender-2.81a-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81a-windows64.zip"],
            sha256 = "87355b0a81d48ea336948294b9da8670eaae73667fae028e9a64cbb4104ceea1",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.81a-linux-glibc217-x86_64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81a-linux-glibc217-x86_64.tar.bz2"],
            sha256 = "08d718505d1eb1d261efba96b0787220a76d357ce5b94aca108fc9e0c339d6c6",
            build_file_content = _build_file_content,
        ),
    },
    "2.82": {
        "windows64": struct(
            strip_prefix = "blender-2.82-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82-windows64.zip"],
            sha256 = "cff722fc0eca42eecd7a423b80c830f11c6dcb9ddff09611b335fa8fc207f42e",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.82-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82-linux64.tar.xz"],
            sha256 = "b13600fa2ca23ea1bba511e3a6599b6792acde80b180707c3ea75db592a9b916",
            build_file_content = _build_file_content,
        ),
    },
    "2.82a": {
        "windows64": struct(
            strip_prefix = "blender-2.82a-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82a-windows64.zip"],
            sha256 = "ce20e5f90df6e8661edce9b7fd5a08fc1cbd26398f3245d994fe2dbf4c6bfdf2",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.82a-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz"],
            sha256 = "fb400258122525c51a5897199197e74010494f71f2b2122c4dd122324e6edebe",
            build_file_content = _build_file_content,
        ),
    },
    "2.83": {
        "windows64": struct(
            strip_prefix = "blender-2.83.0-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.0-windows64.zip"],
            sha256 = "81c9ac55d30627a92f978f28c4682729c7c5dd1ca71bcd3d5701a69cfdcc690b",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.0-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.0-linux64.tar.xz"],
            sha256 = "c817d6c54785095fb3187ef5d5de3bae23c0b2570a8d9926525de7aea52b85c4",
            build_file_content = _build_file_content,
        ),
    },
}

def _os_key(os):
    if os.name.find("windows") != -1:
        return "windows64"
    elif os.name.find("linux") != -1:
        return "linux64"
    return os.name

def _get_blender_archive(rctx):
    blender_version = rctx.attr.blender_version
    archives = _known_blender_archives.get(blender_version)

    if not archives:
        fail("rules_blender unsupported blender_version: {}".format(blender_version))

    archive = archives.get(_os_key(rctx.os))

    if not archive:
        fail("rules_blender unknown blender version / operating system combo: blender_version={} os=".format(blender_version, rctx.os.name))

    return archive

def _blender_repository(rctx):
    archive = _get_blender_archive(rctx)
    rctx.download_and_extract(archive.urls, stripPrefix = archive.strip_prefix, sha256 = archive.sha256)
    rctx.file("BUILD.bazel", archive.build_file_content, executable = False)


blender_repository = repository_rule(
    implementation = _blender_repository,
    attrs = {
        "blender_version": attr.string(
            default = "2.83",
            values = _known_blender_archives.keys()
        )
    },
)
