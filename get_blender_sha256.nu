let release_url = "https://download.blender.org/release"
let version = (input "Blender Version: ");
let short_version = ($version | str trim | split row "." | first 2 | str join ".");
let sha256_values = (http get $"($release_url)/Blender($short_version)/blender-($version).sha256" | lines | split column " " -c sha256 filename);

let windows64_sha256 = ($sha256_values | find windows-x64.zip | get sha256.0);
let linux64_sha256 = ($sha256_values | find linux-x64.tar.xz | get sha256.0);
let macos64_sha256 = ($sha256_values | find macos-x64.dmg | get sha256.0);

echo $"
    '($version)': {
        'windows64': struct\(
            strip_prefix = 'blender-($version)-windows-x64',
            urls = ['{}/Blender($short_version)/blender-($version)-windows-x64.zip'.format\(mirror\) for mirror in _mirrors],
            sha256 = '($windows64_sha256)',
        \),
        'linux64': struct\(
            strip_prefix = 'blender-($version)-linux-x64',
            urls = ['{}/Blender($short_version)/blender-($version)-linux-x64.tar.xz'.format\(mirror\) for mirror in _mirrors],
            sha256 = '($linux64_sha256)',
        \),
        'macos': struct\(
            strip_prefix = '',
            urls = ['{}/Blender($short_version)/blender-($version)-macos-x64.dmg'.format\(mirror\) for mirror in _mirrors],
            sha256 = '($macos64_sha256)',
        \),
    },
"
