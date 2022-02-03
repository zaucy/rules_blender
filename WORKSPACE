workspace(name = "rules_blender")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "bzlws",
    strip_prefix = "bzlws-f929e5380f441f50a77776d34a7df8cacdbdf986",
    url = "https://github.com/zaucy/bzlws/archive/f929e5380f441f50a77776d34a7df8cacdbdf986.zip",
    sha256 = "5bebb821b158b11d81dd25cf031b5b26bae97dbb02025df7d0e41a262b3a030b",
)

load("@bzlws//:repo.bzl", "bzlws_deps")
bzlws_deps()

git_repository(
    name = "io_bazel_stardoc",
    remote = "https://github.com/bazelbuild/stardoc.git",
    commit = "f4d4b3a965c9ae36feeff5eb3171d6ba17406b84",
    shallow_since = "1636567136 -0500",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")
stardoc_repositories()

load("//:repo.bzl", "blender_repository")

blender_repository(name = "blender")
