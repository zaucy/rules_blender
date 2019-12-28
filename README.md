# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-0498f84bbbf7005e72621821ce316a73536de9b4",
    urls = ["https://github.com/zaucy/rules_blender/archive/0498f84bbbf7005e72621821ce316a73536de9b4.zip"],
    sha256 = "8a869bb2d158f078e15ae3accac655b5f5175c14329a634dfa941f207a15df6a",
)

load("@rules_blender//:index.bzl", "blender_repositories")

blender_repositories()
```

## License

MIT
