_windows_build_file_content = """
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

exports_files(["{BLENDER_VERSION}/blender.exe"])

native_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    src = ":blender_wrapper.cmd",
    out = "blender_wrapper.cmd",
    data = ["{BLENDER_VERSION}/blender.exe"],
)
"""

_build_file_content = """
exports_files(["{BLENDER_VERSION}/blender"])

sh_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    srcs = [":blender_wrapper.bash"],
    data = ["{BLENDER_VERSION}/blender"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
)
"""

_blender_wrapper_cmd = """
@echo off

set BLENDER_EXECUTABLE=

for /F "usebackq tokens=*" %%a in (%~dp0%~nx0.runfiles_manifest) do (
    for /F "tokens=1,2" %%b in ("%%a") do (
        if %%b=="blender/blender.exe" do (
            set BLENDER_EXECUTABLE=%%c
            goto :found_blender_executable
        )
    )
)

echo rules_blender (%~nx0) Could not find blender in runfiles manifest
exit 1

:found_blender_executable

set QUIET_OUTPUT=0

set args=
:args_loop
if "%~1"=="" GOTO :start_blender
if /I "%~1"=="--quiet" (
    SET QUIET_OUTPUT=1
    shift & goto :args_loop
)
set args=%args% %~1
shift & goto :args_loop

:start_blender

if %QUIET_OUTPUT%==1 %BLENDER_EXECUTABLE% %args% > NUL
if %QUIET_OUTPUT%==0 %BLENDER_EXECUTABLE% %args%
"""

_blender_wrapper_sh = """
#!/bin/bash

set -e

BLENDER_EXECUTABLE=$0.runfiles/blender/{BLENDER_VERSION}/blender

QUIET_OUTPUT=0
for arg do
    shift
    [ "$arg" = "--quiet" ] && QUIET_OUTPUT=1 && continue
    set -- "$@" "$arg"
done

if [ "$QUIET_OUTPUT" = "1" ]
then
    $BLENDER_EXECUTABLE "$@" > /dev/null
else
    $BLENDER_EXECUTABLE "$@"
fi
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
    "2.83.0": {
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
    "2.83.1": {
        "windows64": struct(
            strip_prefix = "blender-2.83.1-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.1-windows64.zip"],
            sha256 = "69f107823f8e302e2f3f36512cad63c212eda1f44c731d76d0a8c8c7082db293",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.1-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.1-linux64.tar.xz"],
            sha256 = "8e3ad0c639aaed32e5d0db387082a7f061b6d78a356992f8c1a4584fcef71d0b",
            build_file_content = _build_file_content,
        ),
    },
    "2.83.2": {
        "windows64": struct(
            strip_prefix = "blender-2.83.2-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.2-windows64.zip"],
            sha256 = "ac312ed425a007d14477ce5e032431dfa257d91a0aaaf685fa11a80bf4dd6f9c",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.2-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.2-linux64.tar.xz"],
            sha256 = "df77074989c099511fb1131f739738dc1f23d050b3179895dcc90fee918ef68b",
            build_file_content = _build_file_content,
        ),
    },
    "2.83.3": {
        "windows64": struct(
            strip_prefix = "blender-2.83.3-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.3-windows64.zip"],
            sha256 = "ac6ce51627de84e437e0444b3a88524b44345872380c7bae777fd1f5460db263",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.3-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.3-linux64.tar.xz"],
            sha256 = "fc7b1aa9dfd00a9b68720a952d31a2970c1a7737d98f544d647bc78aae85d445",
            build_file_content = _build_file_content,
        ),
    },
    "2.83.4": {
        "windows64": struct(
            strip_prefix = "blender-2.83.4-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.4-windows64.zip"],
            sha256 = "74a6c6baa45a0dd6fb38709a378e13991c7054e0d1044597be7ec228547dbd48",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.4-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.4-linux64.tar.xz"],
            sha256 = "b1a3b8761ae3ed5cb995ee34281ad16f9153f4a69d24d6889ed4e5794b61d342",
            build_file_content = _build_file_content,
        ),
    },
    "2.83.5": {
        "windows64": struct(
            strip_prefix = "blender-2.83.5-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.5-windows64.zip"],
            sha256 = "c598fc1394261a63a13638d49956afb045feae52da7ba721b79fd531d90511de",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.5-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.5-linux64.tar.xz"],
            sha256 = "b126993ed2de0e1e751cf55c29f2bb45d000589e22889e049c9d0bfb2386ba22",
            build_file_content = _build_file_content,
        ),
    },
    "2.90.0": {
        "windows64": struct(
            strip_prefix = "blender-2.90.0-windows64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.0-windows64.zip",
                "https://mirror.clarkson.edu/blender/release/Blender2.90/blender-2.90.0-windows64.zip",
                "https://download.blender.org/release/Blender2.90/blender-2.90.0-windows64.zip",
            ],
            sha256 = "f51e1c33f6c61bdef86008280173e4c5cf9c52e4f5c490e9a7e4db3a355639bc",
            build_file_content = _windows_build_file_content,
        ),
        "linux64": struct(
            strip_prefix = "blender-2.90.0-linux64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.0-linux64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.90/blender-2.90.0-linux64.tar.xz",
                "https://download.blender.org/release/Blender2.90/blender-2.90.0-linux64.tar.xz",
            ],
            sha256 = "d0c9218fa4fc981204d3d187c35b5168b4df4ea71e2e74fb61be1540b935a83c",
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
    rctx.download_and_extract(archive.urls, output = rctx.attr.blender_version, stripPrefix = archive.strip_prefix, sha256 = archive.sha256)
    rctx.file("BUILD.bazel", archive.build_file_content.format(BLENDER_VERSION=rctx.attr.blender_version), executable = False)
    rctx.file("blender_wrapper.cmd", _blender_wrapper_cmd.format(BLENDER_VERSION=rctx.attr.blender_version), executable = True)
    rctx.file("blender_wrapper.bash", _blender_wrapper_sh.format(BLENDER_VERSION=rctx.attr.blender_version), executable = True)

blender_repository = repository_rule(
    implementation = _blender_repository,
    attrs = {
        "blender_version": attr.string(
            default = "2.90.0",
            values = _known_blender_archives.keys()
        )
    },
)
