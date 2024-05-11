module main;

import gio.Application : GioApplication = Application;
import gtk.Application;
import gdk.Threads;
import gdk.Gdk;

import context;

import std.stdio;
import std.process;

int main(string[] args) {
	environment["GDK_BACKEND"] = "wayland";

	// try {
	Gdk.setAllowedBackends("wayland");

	auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
	Context ctx;
	application.addOnActivate(delegate void(GioApplication) {
		ctx = new Context(application, "dbar.yaml", "/home/alex/.config/waybar/style.css");
	});

	return application.run(args);
	// } catch (Exception e) {
	// writeln(e.message);
	// return -1;
	// }

	return 0;
}
