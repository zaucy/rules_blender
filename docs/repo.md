<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#blender_repository"></a>

## blender_repository

<pre>
blender_repository(<a href="#blender_repository-name">name</a>, <a href="#blender_repository-blender_version">blender_version</a>, <a href="#blender_repository-cycles_device_types">cycles_device_types</a>, <a href="#blender_repository-only_system_installed_blender">only_system_installed_blender</a>,
                   <a href="#blender_repository-repo_mapping">repo_mapping</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_repository-blender_version"></a>blender_version |  Blender version. Used to download blender archive.   | String | optional | "3.0.1" |
| <a id="blender_repository-cycles_device_types"></a>cycles_device_types |  -   | List of strings | optional | [] |
| <a id="blender_repository-only_system_installed_blender"></a>only_system_installed_blender |  -   | Boolean | optional | False |
| <a id="blender_repository-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/docs/skylark/lib/dict.html">Dictionary: String -> String</a> | required |  |


