# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-31bd4830a2a6271a5320697588cbf59728b77e54",
    urls = ["https://github.com/zaucy/rules_blender/archive/31bd4830a2a6271a5320697588cbf59728b77e54.zip"],
    sha256 = "35d436ff5f9ae8f856077f8217f0c4de6004fce60203a25e736508244cb47a06",
)

load("@rules_blender//:index.bzl", "blender_repositories")
blender_repositories()
```

## License

MIT
