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

_windows_sys_build_file_content = """
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")

native_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    src = ":blender_wrapper.cmd",
    out = "blender_wrapper.cmd",
)
"""

_macos_build_file_content = """
exports_files(["{BLENDER_VERSION}/Blender.app/Contents/MacOS/Blender"])

sh_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    srcs = [":blender_wrapper.bash"],
    data = ["{BLENDER_VERSION}/Blender.app/Contents/MacOS/Blender"],
    deps = ["@bazel_tools//tools/bash/runfiles"],
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

_sys_build_file_content = """
sh_binary(
    name = "blender",
    visibility = ["//visibility:public"],
    srcs = [":blender_wrapper.bash"],
)
"""

_blender_wrapper_cmd = """
@echo off

set "BLENDER_EXECUTABLE={EXECUTABLE_PATH}"

if NOT "%BLENDER_EXECUTABLE%"=="" (
    if exist %BLENDER_EXECUTABLE% (
        goto :found_blender_executable
    )
)

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
set PREFIX_CD=0

set args=
:args_loop
set arg=%~1
if "%arg%"=="" GOTO :start_blender
if /I "%arg%"=="--quiet" (
    set QUIET_OUTPUT=1
    shift & goto :args_loop
)
if /I "%PREFIX_CD%"=="1" (
    set PREFIX_CD=0
    set arg=%cd%/%arg%
)
if /I "%arg%"=="-o" (
    set PREFIX_CD=1
)
set args=%args% %arg%
shift & goto :args_loop

:start_blender

if %QUIET_OUTPUT%==1 "%BLENDER_EXECUTABLE%" %args% > NUL
if %QUIET_OUTPUT%==0 "%BLENDER_EXECUTABLE%" %args%
"""

_blender_wrapper_sh = """
#!/bin/bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${{RUNFILES_DIR:-/dev/null}}/$f" 2>/dev/null || source "$(grep -sm1 "^$f " "${{RUNFILES_MANIFEST_FILE:-/dev/null}}" | cut -f2- -d' ')" 2>/dev/null || source "$0.runfiles/$f" 2>/dev/null || source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || {{ echo>&2 "ERROR: cannot find $f"; exit 1; }}; f=; set -e
# --- end runfiles.bash initialization v2 ---

BLENDER_EXECUTABLE="{EXECUTABLE_PATH}"

set +e
test -z "$BLENDER_EXECUTABLE" && BLENDER_EXECUTABLE=$(rlocation blender/{BLENDER_VERSION}/blender)
set -e

test -z "$BLENDER_EXECUTABLE" && echo "Cannot find rlocation blender/{BLENDER_VERSION}/blender" && exit 1

QUIET_OUTPUT=0
PREFIX_CD=0
for arg do
    shift
    [ "$arg" = "--quiet" ] && QUIET_OUTPUT=1 && continue
    [ "$PREFIX_CD" = "1" ] && PREFIX_CD=0 && arg=$(pwd)/$arg
    [ "$arg" = "-o" ] && PREFIX_CD=1
    set -- "$@" "$arg"
done

if [ "$QUIET_OUTPUT" = "1" ]
then
    $BLENDER_EXECUTABLE "$@" > /dev/null
else
    $BLENDER_EXECUTABLE "$@"
fi
"""

# https://www.blender.org/download/release/Blender3.0/blender-3.0.0-windows-x64.zip/
_mirrors = [
    "https://mirror.clarkson.edu/blender/release",
    "https://download.blender.org/release",
    "http://ftp.nluug.nl/pub/graphics/blender/release",
    "http://ftp.halifax.rwth-aachen.de/blender/release",
    "https://mirrors.dotsrc.org/blender/blender-release",
]

_platform_build_file_contents = {
    "windows64": struct(
        build_file_content = _windows_build_file_content,
        sys_build_file_content = _windows_sys_build_file_content,
    ),
    "linux64": struct(
        build_file_content = _build_file_content,
        sys_build_file_content = _sys_build_file_content,
    ),
    "macos": struct(
        build_file_content = _macos_build_file_content,
        sys_build_file_content = _sys_build_file_content,
    ),
}

_known_blender_archives = {
    "3.0.0": {
        "windows64": struct(
            strip_prefix = "blender-3.0.0-windows-x64",
            urls = ["{}/Blender3.0/blender-3.0.0-windows-x64.zip".format(mirror) for mirror in _mirrors],
            sha256 = "1d94673d8b8314e75580db6cb3bdaaf3dddf9bdeb70961f04ecb0006b9cc76b3",
        ),
        "linux64": struct(
            strip_prefix = "blender-3.0.0-linux-x64",
            urls = ["{}/Blender3.0/blender-3.0.0-linux-x64.tar.xz".format(mirror) for mirror in _mirrors],
            sha256 = "19b09dfcf5d3f3a068827454f0a704a9aa9c826350f73016121afef5f4d287ce",
        ),
        "macos": struct(
            strip_prefix = "",
            urls = ["{}/Blender3.0/blender-3.0.0-macos-x64.dmg".format(mirror) for mirror in _mirrors],
            sha256 = "ab34d1d1d9aa728e844b78c4673483adc34c4fe0ea61d45e57a386b8a7a5cfc6",
        ),
    },
    "2.81": {
        "windows64": struct(
            strip_prefix = "blender-2.81-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-windows64.zip"],
            sha256 = "b350533d23b678d870a3e78a2a0e27e952dc7db49ab801f00025a148dea0d2f5",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.81-linux-glibc217-x86_64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81-linux-glibc217-x86_64.tar.bz2"],
            sha256 = "e201e7c3dd46aae4a464ec764190199b0ca9ff2e51f9883cd869a4539f33c592",
        ),
    },
    "2.81a": {
        "windows64": struct(
            strip_prefix = "blender-2.81a-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81a-windows64.zip"],
            sha256 = "87355b0a81d48ea336948294b9da8670eaae73667fae028e9a64cbb4104ceea1",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.81a-linux-glibc217-x86_64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.81/blender-2.81a-linux-glibc217-x86_64.tar.bz2"],
            sha256 = "08d718505d1eb1d261efba96b0787220a76d357ce5b94aca108fc9e0c339d6c6",
        ),
    },
    "2.82": {
        "windows64": struct(
            strip_prefix = "blender-2.82-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82-windows64.zip"],
            sha256 = "cff722fc0eca42eecd7a423b80c830f11c6dcb9ddff09611b335fa8fc207f42e",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.82-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82-linux64.tar.xz"],
            sha256 = "b13600fa2ca23ea1bba511e3a6599b6792acde80b180707c3ea75db592a9b916",
        ),
    },
    "2.82a": {
        "windows64": struct(
            strip_prefix = "blender-2.82a-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82a-windows64.zip"],
            sha256 = "ce20e5f90df6e8661edce9b7fd5a08fc1cbd26398f3245d994fe2dbf4c6bfdf2",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.82a-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz"],
            sha256 = "fb400258122525c51a5897199197e74010494f71f2b2122c4dd122324e6edebe",
        ),
    },
    "2.83.0": {
        "windows64": struct(
            strip_prefix = "blender-2.83.0-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.0-windows64.zip"],
            sha256 = "81c9ac55d30627a92f978f28c4682729c7c5dd1ca71bcd3d5701a69cfdcc690b",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.0-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.0-linux64.tar.xz"],
            sha256 = "c817d6c54785095fb3187ef5d5de3bae23c0b2570a8d9926525de7aea52b85c4",
        ),
    },
    "2.83.1": {
        "windows64": struct(
            strip_prefix = "blender-2.83.1-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.1-windows64.zip"],
            sha256 = "69f107823f8e302e2f3f36512cad63c212eda1f44c731d76d0a8c8c7082db293",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.1-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.1-linux64.tar.xz"],
            sha256 = "8e3ad0c639aaed32e5d0db387082a7f061b6d78a356992f8c1a4584fcef71d0b",
        ),
    },
    "2.83.2": {
        "windows64": struct(
            strip_prefix = "blender-2.83.2-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.2-windows64.zip"],
            sha256 = "ac312ed425a007d14477ce5e032431dfa257d91a0aaaf685fa11a80bf4dd6f9c",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.2-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.2-linux64.tar.xz"],
            sha256 = "df77074989c099511fb1131f739738dc1f23d050b3179895dcc90fee918ef68b",
        ),
    },
    "2.83.3": {
        "windows64": struct(
            strip_prefix = "blender-2.83.3-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.3-windows64.zip"],
            sha256 = "ac6ce51627de84e437e0444b3a88524b44345872380c7bae777fd1f5460db263",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.3-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.3-linux64.tar.xz"],
            sha256 = "fc7b1aa9dfd00a9b68720a952d31a2970c1a7737d98f544d647bc78aae85d445",
        ),
    },
    "2.83.4": {
        "windows64": struct(
            strip_prefix = "blender-2.83.4-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.4-windows64.zip"],
            sha256 = "74a6c6baa45a0dd6fb38709a378e13991c7054e0d1044597be7ec228547dbd48",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.4-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.4-linux64.tar.xz"],
            sha256 = "b1a3b8761ae3ed5cb995ee34281ad16f9153f4a69d24d6889ed4e5794b61d342",
        ),
    },
    "2.83.5": {
        "windows64": struct(
            strip_prefix = "blender-2.83.5-windows64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.5-windows64.zip"],
            sha256 = "c598fc1394261a63a13638d49956afb045feae52da7ba721b79fd531d90511de",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.83.5-linux64",
            urls = ["https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.5-linux64.tar.xz"],
            sha256 = "b126993ed2de0e1e751cf55c29f2bb45d000589e22889e049c9d0bfb2386ba22",
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
        ),
        "linux64": struct(
            strip_prefix = "blender-2.90.0-linux64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.0-linux64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.90/blender-2.90.0-linux64.tar.xz",
                "https://download.blender.org/release/Blender2.90/blender-2.90.0-linux64.tar.xz",
            ],
            sha256 = "d0c9218fa4fc981204d3d187c35b5168b4df4ea71e2e74fb61be1540b935a83c",
        ),
    },
    "2.90.1": {
        "windows64": struct(
            strip_prefix = "blender-2.90.1-windows64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.1-windows64.zip",
                "https://mirror.clarkson.edu/blender/release/Blender2.90/blender-2.90.1-windows64.zip",
                "https://download.blender.org/release/Blender2.90/blender-2.90.1-windows64.zip",
            ],
            sha256 = "9939127ac90964984f9a4e6982c29dfcd6337d5ae44537b5c8f3aa371414c9d9",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.90.1-linux64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.90/blender-2.90.1-linux64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.90/blender-2.90.1-linux64.tar.xz",
                "https://download.blender.org/release/Blender2.90/blender-2.90.1-linux64.tar.xz",
            ],
            sha256 = "054668c46a3e56921f283709f51a35f7860786183001cf2ea9be3249d13ac667",
        ),
    },
    "2.91.0": {
        "windows64": struct(
            strip_prefix = "blender-2.91.0-windows64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.0-windows64.zip",
                "https://mirror.clarkson.edu/blender/release/Blender2.91/blender-2.91.0-windows64.zip",
                "https://download.blender.org/release/Blender2.91/blender-2.91.0-windows64.zip",
            ],
            sha256 = "74c0e22b3515ec29683279509f760b59b57f285ab3a70447f5f3c7b1c8f6554b",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.91.0-linux64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.0-linux64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.91/blender-2.91.0-linux64.tar.xz",
                "https://download.blender.org/release/Blender2.91/blender-2.91.0-linux64.tar.xz",
            ],
            sha256 = "1753d27f833ea263d4431329e952fac01f8e8760711e14a21cedec2e09887adf",
        ),
    },
    "2.91.2": {
        "windows64": struct(
            strip_prefix = "blender-2.91.2-windows64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.2-windows64.zip",
                "https://mirror.clarkson.edu/blender/release/Blender2.91/blender-2.91.2-windows64.zip",
                "https://download.blender.org/release/Blender2.91/blender-2.91.2-windows64.zip",
            ],
            sha256 = "52582e09379c36bd7a26d99ec72cbbe2d1d200773e63e73f57ebfc1c1a5918c4",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.91.2-linux64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.91/blender-2.91.2-linux64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.91/blender-2.91.2-linux64.tar.xz",
                "https://download.blender.org/release/Blender2.91/blender-2.91.2-linux64.tar.xz",
            ],
            sha256 = "8f1e1e8852750e1038579336c7461c1a5492da973ce188e1e5cae99b2f796a23",
        ),
    },
    "2.92.0": {
        "windows64": struct(
            strip_prefix = "blender-2.92.0-windows64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.92/blender-2.92.0-windows64.zip",
                "https://mirror.clarkson.edu/blender/release/Blender2.92/blender-2.92.0-windows64.zip",
                "https://download.blender.org/release/Blender2.92/blender-2.92.0-windows64.zip",
            ],
            sha256 = "5ea980be32819e7cf68ecc53ee117aa1ad7da3cb191c8ff3ff3d776574aa3eb8",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.92.0-linux64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.92/blender-2.92.0-linux64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.92/blender-2.92.0-linux64.tar.xz",
                "https://download.blender.org/release/Blender2.92/blender-2.92.0-linux64.tar.xz",
            ],
            sha256 = "2cd17ad6e9d6c241ac14b84ad6e72b507aeec979da3d926b1a146e88e0eb3eb4",
        ),
    },
    "2.93.0": {
        "windows64": struct(
            strip_prefix = "blender-windows64",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.0-windows-x64.zip",
                "https://mirror.clarkson.edu/blender/release/Blender2.93/blender-2.93.0-windows-x64.zip",
                "https://download.blender.org/release/Blender2.93/blender-2.93.0-windows-x64.zip",
            ],
            sha256 = "39a7cab57289e4f814b23f512a66b9c980a4ce1991fc710908be1d632690795a",
        ),
        "linux64": struct(
            strip_prefix = "blender-2.93.0-stable+blender-v293-release.84da05a8b806-linux.x86_64-release",
            urls = [
                "https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.93/blender-2.93.0-linux-x64.tar.xz",
                "https://mirror.clarkson.edu/blender/release/Blender2.93/blender-2.93.0-linux-x64.tar.xz",
                "https://download.blender.org/release/Blender2.93/blender-2.93.0-linux-x64.tar.xz",
            ],
            sha256 = "46b4b2ac3e0ef1768be4f63332d15d8a48bcf5bff18920d3b21e3b8aaaac85e3",
        ),
    },
}

def _os_key(os):
    if os.name.find("windows") != -1:
        return "windows64"
    elif os.name.find("linux") != -1:
        return "linux64"
    elif os.name.find("mac") != -1:
        return "macos"
    return os.name

def _get_blender_archive(rctx, blender_version):
    archives = _known_blender_archives.get(blender_version)

    if not archives:
        fail("rules_blender unsupported blender_version: {}".format(blender_version))

    archive = archives.get(_os_key(rctx.os))

    if not archive:
        fail("rules_blender unknown blender version / operating system combo: blender_version={} os=".format(blender_version, rctx.os.name))

    return archive

def _get_platform_build_file_contents(rctx):
    build_file_contents = _platform_build_file_contents.get(_os_key(rctx.os))

    if not build_file_contents:
        fail("rules_blender unsupported os: os={}".format(rctx.os.name))

    return build_file_contents

def _find_windows_system_installed_blender(rctx):
    blender_base_installdir = rctx.path(rctx.os.environ["ProgramFiles"] + "\\Blender Foundation\\")

    if not blender_base_installdir.exists:
        return None

    dirs = blender_base_installdir.readdir()
    for dir in dirs:
        blender_path = dir.get_child("blender.exe")
        if blender_path.exists:
            return blender_path

    return None

def _find_linux_system_installed_blender(rctx):
    flatpak_install_dir = rctx.path("/var/lib/flatpak/app/org.blender.Blender/current/active/files/blender")
    if flatpak_install_dir.exists:
        return flatpak_install_dir.get_child("blender")
    return None

def _find_system_installed_blender(rctx):
    blender_path = rctx.which("blender")
    if blender_path == None:
        if rctx.os.name.find("windows") != -1:
            return _find_windows_system_installed_blender(rctx)
        else:
            return _find_linux_system_installed_blender(rctx)
    return blender_path

def _download_and_extract_dmg(rctx, archive, blender_version):
    dmg_output_path = "{}.dmg".format(blender_version)
    rctx.download(archive.urls, output = dmg_output_path, sha256 = archive.sha256)
    hdiutil = rctx.which("hdiutil")
    if hdiutil == None:
        fail("Unable to find hdiutil to mount .dmg file")
    
    mountroot = blender_version + "_mountroot"
    mountvolume = rctx.path(mountroot + "/Blender")

    if mountvolume.exists:
        rctx.report_progress("Detaching old {}".format(mountvolume))
        rctx.execute([hdiutil, "detach", mountvolume])

    rctx.report_progress("Attaching {}".format(dmg_output_path))
    hdiutil_attach_args = [hdiutil, "attach", "-noverify", dmg_output_path, "-mountroot", mountroot]
    hdiutil_attach_result = rctx.execute(hdiutil_attach_args)
    if hdiutil_attach_result.return_code != 0:
        fail("Failed to attach .dmg blender image")

    rctx.report_progress("Copying blender installation files")
    
    rctx.execute(["mkdir", blender_version])
    rctx.execute(["cp", "-R", str(mountvolume) + "/", blender_version + "/"])

    rctx.report_progress("Detaching {}".format(mountvolume))
    hdiutil_detach_args = [hdiutil, "detach", mountvolume]
    hdiutil_detach_result = rctx.execute(hdiutil_detach_args)
    if hdiutil_detach_result.return_code != 0:
        fail("Failed to detach blender image")

def _blender_repository(rctx):
    blender_version = str(rctx.attr.blender_version)
    only_system_installed_blender = rctx.attr.only_system_installed_blender

    blender_path = _find_system_installed_blender(rctx)
    if blender_path != None:
        sys_blender_version_args = [blender_path, "--version"]
        sys_blender_version_result = rctx.execute(sys_blender_version_args)
        if sys_blender_version_result.return_code != 0:
            fail("Error while executing {}\n{}".format(" ".join(sys_blender_version_args), sys_blender_version_result.stderr))
        else:
            sys_blender_version = sys_blender_version_result.stdout.split("\n", 1)[0]
            sys_blender_version = sys_blender_version.replace("Blender", "").strip(" ").strip("\n").strip("\r")
            if blender_version == "system":
                blender_version = sys_blender_version
            if sys_blender_version != blender_version and only_system_installed_blender:
                fail("Expected system installed blender version '{}', but instead got '{}'".format(blender_version, sys_blender_version))
    elif blender_path == None and only_system_installed_blender:
        fail("Attribute only_system_installed_blender is set to True, but cannot find system installed blender. If you believe this is a mistake please make an issue at https://github.com/zaucy/rules_blender/issues")

    build_file_contents = _get_platform_build_file_contents(rctx)
    archive = _get_blender_archive(rctx, blender_version)
    blender_executable_path = ""

    if blender_path != None:
        blender_executable_path = str(blender_path)
        rctx.file("BUILD.bazel", build_file_contents.sys_build_file_content.format(BLENDER_VERSION=blender_version), executable = False)
    elif blender_version != "system":
        rctx.file("BUILD.bazel", build_file_contents.build_file_content.format(BLENDER_VERSION=blender_version), executable = False)
        if rctx.os.name.find("mac") != -1:
            blender_executable_path = str(rctx.path(blender_version + "/Blender.app/Contents/MacOS/Blender"))
            _download_and_extract_dmg(rctx, archive, blender_version)
        else:
            rctx.download_and_extract(archive.urls, output = blender_version, stripPrefix = archive.strip_prefix, sha256 = archive.sha256)
    elif blender_version == "system":
        fail("blender_version was set to 'system', but no system installation of blender was found. If you believe this is a mistake please make an issue at https://github.com/zaucy/rules_blender/issues")

    rctx.file("blender_wrapper.cmd", _blender_wrapper_cmd.format(BLENDER_VERSION=blender_version, EXECUTABLE_PATH=blender_executable_path.replace("/", "\\")), executable = True)
    rctx.file("blender_wrapper.bash", _blender_wrapper_sh.format(BLENDER_VERSION=blender_version, EXECUTABLE_PATH=blender_executable_path), executable = True)

blender_repository = repository_rule(
    implementation = _blender_repository,
    attrs = {
        "only_system_installed_blender": attr.bool(),
        "blender_version": attr.string(
            default = "3.0.0",
            values = _known_blender_archives.keys() + ["system"],
            doc = "Blender version. Used to download blender archive.",
        )
    },
)
