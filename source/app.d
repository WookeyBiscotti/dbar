/*
 * This file is part of gtkD.
 *
 * gtkD is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * gtkD is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with gtkD; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110, USA
 */

import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Label;

import gtk_layer_shell;

class HelloWorld : ApplicationWindow
{
	this(Application app)
	{
		// Create a normal GTK window however you like
		// auto gtk_window = app.getActiveWindow().getWindowStruct();

		// Before the window is first realized, set it up to be a layer surface
		// gtk_layer_init_for_window(gtk_window);

		// Order below normal windows
		// gtk_layer_set_layer(gtk_window, GtkLayerShellLayer.GTK_LAYER_SHELL_LAYER_BOTTOM);

		// Push other windows out of the way
		// gtk_layer_auto_exclusive_zone_enable(gtk_window);

		// We don't need to get keyboard inputqq
		// gtk_layer_set_keyboard_mode (gtk_window, GTK_LAYER_SHELL_KEYBOARD_MODE_NONE); // NONE is default

		// The margins are the gaps around the window's edges
		// Margins and anchors can be set like this...
		// gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_LEFT, 40);
		// gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_RIGHT, 40);
		// gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_TOP, 20);
		// gtk_layer_set_margin (gtk_window, GTK_LAYER_SHELL_EDGE_BOTTOM, 0); // 0 is default

		// ... or like this
		// Anchors are if the window is pinned to each edge of the output

		super(app);
		setTitle("GtkD");
		setBorderWidth(10);
		add(new Label("Hello World"));

		showAll();
	}
}

int main(string[] args)
{
	// import gtkd.Loader;

	// Linker.dumpLoadLibraries();
	// Linker.dumpFailedLoads();

	import std;

	writeln(gtk_layer_get_major_version());

	auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
	application.addOnActivate(delegate void(GioApplication app) {
		auto w = new HelloWorld(application);

				// Create a normal GTK window however you like
		auto gtk_window = w.getWindowStruct();

		// Before the window is first realized, set it up to be a layer surface
		gtk_layer_init_for_window(gtk_window);

				// Order below normal windows
		gtk_layer_set_layer(gtk_window, GtkLayerShellLayer.GTK_LAYER_SHELL_LAYER_BOTTOM);

		// Push other windows out of the way
		gtk_layer_auto_exclusive_zone_enable(gtk_window);
	});
	return application.run(args);
}
