#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <unordered_map>
#include <filesystem>
#include <atomic>
#include <array>
#include <boost/process.hpp>
#include <boost/asio.hpp>
#include "docopt.h"
#include <google/protobuf/util/delimited_message_util.h>
#include <google/protobuf/io/zero_copy_stream_impl.h>
#include <google/protobuf/util/json_util.h>
#include "src/main/protobuf/worker_protocol.pb.h"
#include "tools/cpp/runfiles/runfiles.h"

namespace fs = std::filesystem;
namespace bp = boost::process;

constexpr int stdin_file_descriptor = 0;
constexpr int stdout_file_descriptor = 1;

static const char USAGE[] = R"(
blender_worker - Run Blender as a 'worker' designed for Bazel

Usage:
  blender_worker --blender=PATH [--persistent_worker] 
                 [--blender_worker_script=PATH]
  blender_worker (-h | --help)

Options:
  -h --help  Shows this help text.
  --blender=PATH  Path to blender executable that the worker should use.
  --blender_worker_script=PATH  Path to blender worker python script. If unset
                                it will be looked for in bazel runfiles.
  --persistent_worker  If present the process will persist for work requests.
                       otherwise the worker will exit after 1 work request.
)";

struct blender_worker_options {
	fs::path blender_path;
	fs::path blender_worker_script_path;
	bool persistent_worker;
};

static blender_worker_options parse_argv(int argc, char *argv[]);

class blender_work {
public:
	blender_work
		( blaze::worker::WorkRequest request
		);

	bool done() const noexcept;

private:
	std::atomic_bool _done;
	blaze::worker::WorkRequest _request;
};

int main(int argc, char *argv[]) {
	using google::protobuf::io::FileInputStream;
	using google::protobuf::io::FileOutputStream;
	using google::protobuf::util::ParseDelimitedFromZeroCopyStream;
	using google::protobuf::util::SerializeDelimitedToZeroCopyStream;
	using google::protobuf::util::MessageToJsonString;
	using blaze::worker::WorkRequest;
	using blaze::worker::WorkResponse;
	using blaze::worker::Input;
	using tcp = boost::asio::ip::tcp;

	boost::asio::io_context ioc;
	tcp::socket sock(ioc, tcp::endpoint(tcp::v4(), 0));

	const auto options = parse_argv(argc, argv);

	bp::child blender_process(
		options.blender_path.string(),
		bp::args(std::array<std::string, 8>{
			"-b", "--factory-startup", "-noaudio",
			"-P", options.blender_worker_script_path.string(),
			"--",
			"--blender_worker_port", std::to_string(sock.local_endpoint().port()),
		})
	);

	std::freopen(NULL, "rb", stdin);

	FileInputStream istream(stdin_file_descriptor);
	FileOutputStream ostream(stdout_file_descriptor);

	std::unordered_map<google::protobuf::int32, blender_work> work_map;

	WorkRequest request;
	bool clean_eof;
	for(;;) {
		bool parse_success = ParseDelimitedFromZeroCopyStream(
			&request,
			&istream,
			&clean_eof
		);

		if(parse_success) {
			auto request_id = request.request_id();
			auto [itr, emplaced] = work_map.try_emplace(request_id, request);
			if(!emplaced) {
				WorkResponse response;
				response.set_request_id(request_id);
				response.set_exit_code(1);
				response.set_output("[WORKER ERROR] request_id already exists");

				if(!SerializeDelimitedToZeroCopyStream(response, &ostream)) {
					break;
				}
			} else {
				
			}
		}
	}
}

blender_worker_options parse_argv(int argc, char *argv[]) {
	using bazel::tools::cpp::runfiles::Runfiles;

	auto args = docopt::docopt(USAGE, {argv + 1, argv + argc});
	std::string blender_worker_script_path;
	if(args["--blender_worker_script_path"]) {
		blender_worker_script_path =
			args["--blender_worker_script_path"].asString();
	} else {
		std::string error;
		std::unique_ptr<Runfiles> runfiles(Runfiles::Create(argv[0], &error));

		blender_worker_script_path =
			runfiles->Rlocation("rules_blender/blender_worker/blender_worker.py");
	}

	if(blender_worker_script_path.empty()) {
		std::cerr
			<< "[ERROR] Unable to find blender worker python script"
			<< std::endl;
		std::abort();
	}

	return {
		.blender_path = fs::path(args["--blender"].asString()),
		.blender_worker_script_path = fs::path(blender_worker_script_path),
		.persistent_worker = args["--persistent_worker"].asBool(),
	};
}
