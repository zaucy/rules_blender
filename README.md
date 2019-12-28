# rules_blender

[Bazel](https://bazel.build) rules for rendering .blend files with [Blender](https://www.blender.org/)

## Install

Add this to your `WORKSPACE`

```python
http_archive(
    name = "rules_blender",
    strip_prefix = "rules_blender-cad549ac800a6bd31836e44200f59f2cdb0dba96",
    urls = ["https://github.com/zaucy/rules_blender/archive/cad549ac800a6bd31836e44200f59f2cdb0dba96.zip"],
    sha256 = "546c5a3e5acfcc52728b8fffe2ccf369fc57950291998c8fbdd8737363eba329",
)

load("@rules_blender//:index.bzl", "blender_repositories")
blender_repositories()
```

## License

MIT
