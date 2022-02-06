workspace(name = "rules_blender")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "bzlws",
    sha256 = "1cfcdca3c67ff760000843df9d050946da52a7d50a9fc6e7877f3fcea283db83",
    strip_prefix = "bzlws-a8f3e4b0bc168059ec92971b1ea7c214db2c5454",
    url = "https://github.com/zaucy/bzlws/archive/a8f3e4b0bc168059ec92971b1ea7c214db2c5454.zip",
)

load("@bzlws//:repo.bzl", "bzlws_deps")

bzlws_deps()

git_repository(
    name = "io_bazel_stardoc",
    commit = "f4d4b3a965c9ae36feeff5eb3171d6ba17406b84",
    remote = "https://github.com/bazelbuild/stardoc.git",
    shallow_since = "1636567136 -0500",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")

stardoc_repositories()

load("//:repo.bzl", "blender_repository")

blender_repository(name = "blender")
