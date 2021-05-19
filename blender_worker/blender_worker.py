import sys
import asyncio
import argparse
import bpy
from bpy.app.handlers import persistent

def parse_argv(argv = sys.argv):
	parser = argparse.ArgumentParser(prog = "blender_worker")
	parser.add_argument(
		"--blender_worker_port",
		dest = "blender_worker_port",
	)

	# Arguments that get passed after '--' are for our script
	startArgsIndex = argv.index('--')
	args = argv[startArgsIndex+1:]

	return parser.parse_args(args)

@persistent
def load_handler(dummy):
	print("Load Handler:", bpy.data.filepath, file = sys.stderr)

async def main():
	args = parse_argv()
	bpy.app.handlers.load_post.append(load_handler)

asyncio.run(main())
