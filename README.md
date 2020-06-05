# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-<COMMIT_HASH>",
    urls = ["https://github.com/zaucy/rules_blender/archive/<COMMIT_HASH>.zip"],
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
