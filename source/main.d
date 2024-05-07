module main;

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

private import gdk.Screen;
private import gdkpixbuf.Pixbuf;
private import glib.ConstructionException;
private import glib.ErrorG;
private import glib.GException;
private import glib.ListG;
private import glib.Str;
private import gobject.ObjectG;
private import gobject.Signals;
private import gtk.AccelGroup;
private import gdk.Gdk;
private import gtk.Application;
private import gtk.CssProvider;
private import gtk.StyleContext;
private import gtk.Bin;
private import gdk.Screen;
private import gtk.Widget;
private import gtk.WindowGroup;
private import gtk.c.functions;
public import gtk.c.types;
public import gtkc.gtktypes;
private import std.algorithm;

import utils;

import context;

// import parser.window_info;
import dom.window;
import widgets.label;

import gtk_layer_shell;
import dyaml;

// class HelloWorld : ApplicationWindow
// {
// 	this(Application app)
// 	{
// 		super(app);

// 		auto gtk_window = cast(GtkWindow*) this.getApplicationWindowStruct();

// 		// gtk_layer_init_for_window(gtk_window);

// 		// gtk_layer_set_layer(gtk_window, GtkLayerShellLayer.GTK_LAYER_SHELL_LAYER_TOP);

// 		// gtk_layer_auto_exclusive_zone_enable(gtk_window);

// 		// auto gtk_window = cast(GtkWindow*) gtk_application_window_new(app.getGtkApplicationStruct());
// 		// Create a normal GTK window however you like
// 		// auto gtk_window = app.getActiveWindow().getWindowStruct();

// 		// Before the window is first realized, set it up to be a layer surface
// 		gtk_layer_init_for_window(gtk_window);

// 		// Order below normal windows
// 		// gtk_layer_set_layer(gtk_window, GtkLayerShellLayer.GTK_LAYER_SHELL_LAYER_BOTTOM);

// 		// Push other windows out of the way

// 		// We don't need to get keyboard inputqq
// 		// gtk_layer_set_keyboard_mode (gtk_window, GTK_LAYER_SHELL_KEYBOARD_MODE_NONE); // NONE is default

// 		// The margins are the gaps around the window's edges
// 		// Margins and anchors can be set like this...
// 		// gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_LEFT, 40);
// 		// gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_RIGHT, 40);
// 		// gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_TOP, 20);
// 		gtk_layer_set_margin(gtk_window, GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_BOTTOM, 0); // 0 is default

// 		// // ... or like this
// 		// // Anchors are if the window is pinned to each edge of the output

// 		// gtk_layer_auto_exclusive_zone_enable(gtk_window);
// 		// gtk_layer_set_exclusive_zone(gtk_window, 10);

// 		static const int[] anchors = [1, 1, 0, 1];
// 		for (int i = 0; i < GtkLayerShellEdge.GTK_LAYER_SHELL_EDGE_ENTRY_NUMBER; i++)
// 		{
// 			gtk_layer_set_anchor(gtk_window, cast(GtkLayerShellEdge) i, anchors[i]);
// 		}

// 		gtk_layer_set_layer(gtk_window, GtkLayerShellLayer.GTK_LAYER_SHELL_LAYER_BOTTOM);

// 		// gtk_layer_auto_exclusive_zone_enable(gtk_window);
// 		// gtk_layer_set_exclusive_zone(gtk_window, 10);

// 		// ... or like this
// 		// Anchors are if the window is pinned to each edge of the output

// 		// Before the window is first realized, set it up to be a layer surface
// 		// gtk_layer_init_for_window(gtk_window);

// 		// setTitle("GtkD");
// 		// setBorderWidth(10);
// 		add(new Label("Hello World"));

// 		showAll();
// 	}
// }

import std;

int main(string[] args) {
	try {
		Gdk.setAllowedBackends("wayland");

		auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
		// Display

		auto provider = new CssProvider;
		provider.loadFromPath("/home/alex/.config/waybar/style.css");

		auto ctx = new Context(application);
		WindowNode window;

		application.addOnActivate(delegate void(GioApplication app) {
			writeln(getMonitorsPlugNames());
			auto root = Loader.fromFile("dbar.yaml").load();
			foreach (pair; root["windows"].mapping) {
				window = new WindowNode(ctx, pair.key.as!string, pair.value);
				window.setStyleProvider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
				window.show();
			}
		});
		// auto ctx = new StyleContext;
		// ctx.addProvider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);

		return application.run(args);
	} catch (Throwable e) {
		writeln(e.message);
	}

	return -1;
}
