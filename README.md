# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-f0659db5ce00ceb181c67cfe290eb50321129ffe",
    urls = ["https://github.com/zaucy/rules_blender/archive/f0659db5ce00ceb181c67cfe290eb50321129ffe.zip"],
    sha256 = "27ac3d88384befff56ee11a564dcd7bb28329730304e59d88fbf010e4cd5a626",
)

load("@rules_blender//:index.bzl", "blender_repositories")

blender_repositories()
```

## License

MIT
