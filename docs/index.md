<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="#blender_library"></a>

## blender_library

<pre>
blender_library(<a href="#blender_library-name">name</a>, <a href="#blender_library-srcs">srcs</a>)
</pre>

Group .blend files and images together to be used as `deps` in `blender_render`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_library-srcs"></a>srcs |  List of blend files and image files   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |


<a id="#blender_render"></a>

## blender_render

<pre>
blender_render(<a href="#blender_render-name">name</a>, <a href="#blender_render-batch_render">batch_render</a>, <a href="#blender_render-blend_file">blend_file</a>, <a href="#blender_render-blender_executable">blender_executable</a>, <a href="#blender_render-deps">deps</a>,
               <a href="#blender_render-enable_cycles_devices_script">enable_cycles_devices_script</a>, <a href="#blender_render-frame_end">frame_end</a>, <a href="#blender_render-frame_start">frame_start</a>, <a href="#blender_render-python_script_args">python_script_args</a>,
               <a href="#blender_render-python_scripts">python_scripts</a>, <a href="#blender_render-render_engine">render_engine</a>, <a href="#blender_render-render_format">render_format</a>, <a href="#blender_render-scene">scene</a>)
</pre>

Render a .blend file in to a list of frames

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_render-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_render-batch_render"></a>batch_render |  Number of frames to render at a time. If <code>0</code> all the frames will be rendered at once.   | Integer | optional | 0 |
| <a id="blender_render-blend_file"></a>blend_file |  Blend file to render   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="blender_render-blender_executable"></a>blender_executable |  Blender executable to use for the render.   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @blender//:blender |
| <a id="blender_render-deps"></a>deps |  <code>blender_library</code> dependencies   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="blender_render-enable_cycles_devices_script"></a>enable_cycles_devices_script |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @blender//:enable_cycles_devices.py |
| <a id="blender_render-frame_end"></a>frame_end |  End frame in animation   | Integer | required |  |
| <a id="blender_render-frame_start"></a>frame_start |  Start frame in animation   | Integer | required |  |
| <a id="blender_render-python_script_args"></a>python_script_args |  Arguments to pass to blender after '--'. Typically handled by the script the <code>python_script</code> attribute.   | List of strings | optional | [] |
| <a id="blender_render-python_scripts"></a>python_scripts |  Python scripts to run right before render begins   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="blender_render-render_engine"></a>render_engine |  Render engine to use. If <code>"UNSET"</code> then the render engine set in the blend file is used.   | String | optional | "UNSET" |
| <a id="blender_render-render_format"></a>render_format |  Render format. [See blender documentation](https://docs.blender.org/manual/en/latest/advanced/command_line/arguments.html#format-options)   | String | required |  |
| <a id="blender_render-scene"></a>scene |  Scene to render. If not set the default scene in the blend file is used.   | String | optional | "" |


<a id="#blender_script"></a>

## blender_script

<pre>
blender_script(<a href="#blender_script-name">name</a>, <a href="#blender_script-autoexec_scripts">autoexec_scripts</a>, <a href="#blender_script-blend_file">blend_file</a>, <a href="#blender_script-blender_executable">blender_executable</a>, <a href="#blender_script-outs">outs</a>, <a href="#blender_script-python_script">python_script</a>,
               <a href="#blender_script-python_script_args">python_script_args</a>, <a href="#blender_script-scene">scene</a>)
</pre>

Run a python script in blender on a specific blend file to get an output

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_script-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_script-autoexec_scripts"></a>autoexec_scripts |  Enable automatic Python script execution   | Boolean | optional | False |
| <a id="blender_script-blend_file"></a>blend_file |  Blend file to run the script on   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="blender_script-blender_executable"></a>blender_executable |  Blender executable to use   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @blender//:blender |
| <a id="blender_script-outs"></a>outs |  Output files the python_script writes to. These get passed to in format -o path/to/output/file   | List of labels | required |  |
| <a id="blender_script-python_script"></a>python_script |  Python script to run   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="blender_script-python_script_args"></a>python_script_args |  Arguments to pass to blender after '--' and the built in -o arguments   | List of strings | optional | [] |
| <a id="blender_script-scene"></a>scene |  Scene to set before running python script (optional)   | String | optional | "" |


<a id="#blender_test"></a>

## blender_test

<pre>
blender_test(<a href="#blender_test-name">name</a>, <a href="#blender_test-autoexec_scripts">autoexec_scripts</a>, <a href="#blender_test-blend_file">blend_file</a>, <a href="#blender_test-blender_executable">blender_executable</a>, <a href="#blender_test-data">data</a>, <a href="#blender_test-python_script">python_script</a>,
             <a href="#blender_test-python_script_args">python_script_args</a>, <a href="#blender_test-scene">scene</a>)
</pre>

Run a python script in blender on a specific blend file as a test

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="blender_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="blender_test-autoexec_scripts"></a>autoexec_scripts |  Enable automatic Python script execution   | Boolean | optional | False |
| <a id="blender_test-blend_file"></a>blend_file |  Blend file to run the script on   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | required |  |
| <a id="blender_test-blender_executable"></a>blender_executable |  Blender executable to use   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @blender//:blender |
| <a id="blender_test-data"></a>data |  -   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="blender_test-python_script"></a>python_script |  Python script to run   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |
| <a id="blender_test-python_script_args"></a>python_script_args |  Arguments to pass to blender after '--'   | List of strings | optional | [] |
| <a id="blender_test-scene"></a>scene |  Scene to set before running python script (optional)   | String | optional | "" |


<a id="#BlenderLibraryInfo"></a>

## BlenderLibraryInfo

<pre>
BlenderLibraryInfo()
</pre>



**FIELDS**



