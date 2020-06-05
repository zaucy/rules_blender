# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-1af9c5935908adaaa645e597112a919f19d5f59c",
    urls = ["https://github.com/zaucy/rules_blender/archive/1af9c5935908adaaa645e597112a919f19d5f59c.zip"],
    sha256 = "651f0f015efdba4fa9fbe0d046080022fbb72117fa9f361bc59632c971b2ae38",
)

load("@rules_blender//:index.bzl", "blender_repository")
blender_repository()
```

## Rules

### `blender_render`

```python
blender_render(blend_file, batch_render, render_engine, render_format, scene, frame_start, frame_end, blender_executable)
```

## License

MIT
