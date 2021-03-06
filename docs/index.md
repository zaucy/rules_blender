<!-- Generated with Stardoc: http://skydoc.bazel.build -->

<a id="#blender_library"></a>

## blender_library

<pre>
blender_library(<a href="#blender_library-name">name</a>, <a href="#blender_library-srcs">srcs</a>)
</pre>

Group .blend files together to be used as `deps` in `blender_render`. Usually used when the .blend files in `srcs` are linked to a .blend file in `blender_render`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_library-srcs"></a>srcs |  List of blend files   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


<a id="#blender_render"></a>

## blender_render

<pre>
blender_render(<a href="#blender_render-name">name</a>, <a href="#blender_render-autoexec_scripts">autoexec_scripts</a>, <a href="#blender_render-batch_render">batch_render</a>, <a href="#blender_render-blend_file">blend_file</a>, <a href="#blender_render-blender_executable">blender_executable</a>, <a href="#blender_render-deps">deps</a>,
               <a href="#blender_render-frame_end">frame_end</a>, <a href="#blender_render-frame_start">frame_start</a>, <a href="#blender_render-python_script">python_script</a>, <a href="#blender_render-render_engine">render_engine</a>, <a href="#blender_render-render_format">render_format</a>, <a href="#blender_render-scene">scene</a>)
</pre>

Render a .blend file in to a list of frames

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_render-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_render-autoexec_scripts"></a>autoexec_scripts |  Enable automatic Python script execution   | Boolean | optional | False |
| <a id="blender_render-batch_render"></a>batch_render |  Number of frames to render at a time. If <code>0</code> all the frames will be rendered at once.   | Integer | optional | 0 |
| <a id="blender_render-blend_file"></a>blend_file |  Blend file to render   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="blender_render-blender_executable"></a>blender_executable |  Blender executable to use for the render.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @blender//:blender |
| <a id="blender_render-deps"></a>deps |  <code>blender_library</code> dependencies   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="blender_render-frame_end"></a>frame_end |  End frame in animation   | Integer | required |  |
| <a id="blender_render-frame_start"></a>frame_start |  Start frame in animation   | Integer | required |  |
| <a id="blender_render-python_script"></a>python_script |  Python script to run right before render begins   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="blender_render-render_engine"></a>render_engine |  Render engine to use. If <code>"UNSET"</code> then the render engine set in the blend file is used.   | String | optional | "UNSET" |
| <a id="blender_render-render_format"></a>render_format |  Render format. [See blender documentation](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html#format-options)   | String | required |  |
| <a id="blender_render-scene"></a>scene |  Scene to render. If not set the default scene in the blend file is used.   | String | optional | "" |


<a id="#BlenderLibraryInfo"></a>

## BlenderLibraryInfo

<pre>
BlenderLibraryInfo()
</pre>



**FIELDS**



