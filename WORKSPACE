workspace(name = "rules_blender")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

http_archive(
    name = "bazel_skylib",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.3/bazel-skylib-1.0.3.tar.gz",
    ],
    sha256 = "1c531376ac7e5a180e0237938a2536de0c54d93f5c278634818e0efc952dd56c",
)
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

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
    commit = "247c2097e7346778ac8d03de5a4770d6b9890dc5",
    shallow_since = "1600270745 -0400",
)

load("@io_bazel_stardoc//:setup.bzl", "stardoc_repositories")
stardoc_repositories()

git_repository(
    name = "bazel_compdb",
    remote = "git@github.com:grailbio/bazel-compilation-database.git",
    commit = "9682280a2f7e014e870e2654f1e788345bdf0559",
    shallow_since = "1603518373 -0700",
)

http_archive(
    name = "bazelregistry_docopt_cpp",
    strip_prefix = "docopt.cpp-80509cca48b7a865fa8316518add6a7d7d23aa23",
    url = "https://github.com/bazelregistry/docopt.cpp/archive/80509cca48b7a865fa8316518add6a7d7d23aa23.zip",
    sha256 = "a4d17a8801c043773be320fb542f870c8e9e4c0b412bd0e8099ec3b91f9a3ef7",
)

http_archive(
    name = "com_google_protobuf",
    strip_prefix = "protobuf-3.17.0",
    urls = ["https://github.com/protocolbuffers/protobuf/releases/download/v3.17.0/protobuf-all-3.17.0.tar.gz"],
    sha256 = "96da1cb0648c7c1b2e68ef7089149dce18ecf8d0582a171315b3991a59e629c6",
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
protobuf_deps()

http_archive(
    name = "rules_python",
    url = "https://github.com/bazelbuild/rules_python/releases/download/0.2.0/rules_python-0.2.0.tar.gz",
    sha256 = "778197e26c5fbeb07ac2a2c5ae405b30f6cb7ad1f5510ea6fdac03bded96cc6f",
)

http_archive(
    name = "boost",
    strip_prefix = "boost-7ffa896bfff216a3bfedb2cbac1933f8e31066bc",
    urls = ["https://github.com/bazelboost/boost/archive/7ffa896bfff216a3bfedb2cbac1933f8e31066bc.zip"],
    sha256 = "1c5e5466c17b2918b7c9adb181cad490db3bea2f02b15cd73b11b1506016ab9c",
)

load("@boost//:index.bzl", "boost_http_archives")
boost_http_archives()
