# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Roadmap

- [ ] Blender render with [persistent workers](https://docs.bazel.build/versions/4.1.0/persistent-workers.html)
- [ ] Sandbox blender render or script dependencies to improve deterministic builds

## Install

Add this to your `WORKSPACE`

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# rules_blender requires bazel_skylib on windows
http_archive(
    name = "bazel_skylib",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
    ],
    sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-996f43e92ee00433830ae1235078ef343d1c0c10",
    urls = ["https://github.com/zaucy/rules_blender/archive/996f43e92ee00433830ae1235078ef343d1c0c10.zip"],
    sha256 = "870d91b359a6d57f07a0d34b64061f690b1cf53d3ed0936158bd2a796ff9142d",
)

load("@rules_blender//:repo.bzl", "blender_repository")
# NOTE: If you do not set the blender_repository name to "blender" you will have
# to pass in your `blender_executable` for each `blender_render` rule
blender_repository(name = "blender")
```

## Rules

[See documentation](docs/README.md)

## License

MIT
