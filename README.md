# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-c937bcd12f2059d8f0303cea4c9da242e90213fd",
    urls = ["https://github.com/zaucy/rules_blender/archive/c937bcd12f2059d8f0303cea4c9da242e90213fd.zip"],
    sha256 = "3b5afd11f681a80d8b6c65e31ddaf0ca7e563956661aebcdfc8402800f1aaed1",
)

load("@rules_blender//:index.bzl", "blender_repositories")
blender_repositories()
```

## License

MIT
