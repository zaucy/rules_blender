# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-2845be26f025008e4c9d502a93795fa62d18585f",
    urls = ["https://github.com/zaucy/rules_blender/archive/2845be26f025008e4c9d502a93795fa62d18585f.zip"],
    sha256 = "e29aa8906fc51248e5467ea3591edcd0c6a0c06b872de8a3b82a6b66c83c6caf",
)

load("@rules_blender//:index.bzl", "blender_repositories")
blender_repositories()
```

## License

MIT
