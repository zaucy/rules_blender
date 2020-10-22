workspace(name = "rules_blender")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "bzlws",
    strip_prefix = "bzlws-bfd19cc5d1d85fc7c45ea1c186824bd38abdcab4",
    url = "https://github.com/zaucy/bzlws/archive/bfd19cc5d1d85fc7c45ea1c186824bd38abdcab4.zip",
    sha256 = "e77b287efd27508e27bc3c11ccbddb57a270dcdb59e2b5e105a52a71c24c510f",
)

load("@bzlws//:index.bzl", "bzlws_deps")
bzlws_deps()

git_repository(
    name = "io_bazel_stardoc",
    remote = "https://github.com/bazelbuild/stardoc.git",
    commit = "247c2097e7346778ac8d03de5a4770d6b9890dc5",
    shallow_since = "1600270745 -0400",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")
stardoc_repositories()
