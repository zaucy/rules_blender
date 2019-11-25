# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-2ef642bccfa35dce2e07e66eeb3f04e95a0d4611",
    urls = ["https://github.com/zaucy/rules_blender/archive/2ef642bccfa35dce2e07e66eeb3f04e95a0d4611.zip"],
    sha256 = "9ec59c606d85d559ac886bb76b7604fa17b0d7bd132faa84965941a93ed5af94",
)

load("@rules_blender//:index.bzl", "blender_repositories")

blender_repositories()
```

## License

MIT
