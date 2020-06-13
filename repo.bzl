_windows_build_file_content = """
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
native_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    src = ":blender_wrapper.cmd",
    out = "blender_wrapper.cmd",
    data = ["blender.exe"],
)
"""

_build_file_content = """
sh_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    srcs = [":blender_wrapper.sh"],
    data = ["blender_bin"],
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

:args_loop
if "%~1"=="" GOTO :start_blender
if /I "%~1"=="--quiet" SET QUIET_OUTPUT=1
shift & goto :args_loop

:start_blender

if %QUIET_OUTPUT%==1 do (%BLENDER_EXECUTABLE% %* > NUL)
if %QUIET_OUTPUT%==0 do (%BLENDER_EXECUTABLE% %*)
"""
_blender_wrapper_sh = """
#!/bin/sh

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
    source "$0.runfiles/$f" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
    source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
    { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

set -e

if [[ $* == *--quiet ]]
then
    $(rlocation blender/blender_bin) "$@" > /dev/null
else
    $(rlocation blender/blender_bin) "$@"
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
    rctx.symlink("blender", "blender_bin")
    rctx.file("BUILD.bazel", archive.build_file_content, executable = False)
    rctx.file("blender_wrapper.cmd", _blender_wrapper_cmd, executable = True)
    rctx.file("blender_wrapper.sh", _blender_wrapper_sh, executable = True)


blender_repository = repository_rule(
    implementation = _blender_repository,
    attrs = {
        "blender_version": attr.string(
            default = "2.83",
            values = _known_blender_archives.keys()
        )
    },
)
