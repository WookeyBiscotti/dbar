module main;

import gio.Application : GioApplication = Application;
import gtk.Application;
import gdk.Threads;
import gdk.Gdk;

// import context;

import std.stdio;
import std.process;
import std.getopt;

import dwd.dwd;
import dwd.dwd_client;

import ipc.commands;

int main(string[] args) {
	string appPath = args[0];

	string configPath;
	bool debugLog = false;
	auto opts = getopt(args, //
		"config|c", &configPath, //
		"debug|d", &debugLog, //
		);
	args = args[1 .. $];

	if (!args || !args.length || opts.helpWanted) {
		defaultGetoptPrinter("Help", opts.options);

		return 0;
	}

	if (args[0] == "daemon") {
		// import std.concurrency;
		// import core.thread;

		// auto dg = () shared{ auto d = new DWD([]); d.ipcThread(); };
		// spawn(dg);

		auto d = new DWD([]);
		d.run();

		return 0;
	}

	auto client = new DWDClient(DWDClientConfig(debugLog));
	auto resp = client.sendCommand(args[0], makeRequest(args[0], args[1 .. $]));

	if (resp) {
		writeln(resp.msg());
	} else {
		writeln("Can't connect to daemon");
	}

	return 0;

	// if (args.length > 1) {
	// 	auto c = new DWDClient;
	// 	c.sendStrCommand(args[1]);
	// 	return 0;
	// } else {
	// 	auto d = new DWD(args);
	// 	d.ipcThread();
	// }

	// return;

	// environment["GDK_BACKEND"] = "wayland";

	// try {
	// Gdk.setAllowedBackends("wayland");

	// auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
	// Context ctx;
	// application.addOnActivate(delegate void(GioApplication) {
	// 	ctx = new Context(application, "dbar.yaml", "/home/alex/.config/waybar/style.css");
	// });

	// return application.run(args);
	// } catch (Exception e) {
	// writeln(e.message);
	// return -1;
	// }

	return 0;
}
