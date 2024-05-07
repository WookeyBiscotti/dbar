module context;

import std.string;
import std.array;
import std.conv;

import gtk.Application;
import gdk.Display;
import gdk.Screen;
import gdk.MonitorG;

import gtk_layer_shell;

class Context {
    this(Application app) {
        this.app = app;
    }

    string resolve(string value) {
        if (value.startsWith("${") && value.endsWith("}")) {
            import core.stdc.stdlib;

            throw new Exception("Not implemented");
        } else {
            return value;
        }
    }

    int resolveInWindowHeight(string value, int displayHeight) {
        auto resolved = resolve(value);

        if (resolved.endsWith("%")) {
            return resolved[0 .. $ - 1].to!int * displayHeight / 100;
        } else {
            return resolved.to!int;
        }
    }

    int resolveInWindowWidth(string value, int displayWidth) {
        auto resolved = resolve(value);

        if (resolved.endsWith("%")) {
            return resolved[0 .. $ - 1].to!int * displayWidth / 100;
        } else {
            return resolved.to!int;
        }
    }

    // uint displayWidth() {
    //     auto display = app.getActiveWindow().getDisplay();
    //     // auto m = new MonitorG(gtk_layer_get_monitor(app.getActiveWindow().getWindowStruct()));
    //     // auto m = display.getMonitor(0);
    //     // GdkRectangle geometry;
    //     // m.getGeometry(geometry);

    //     auto monitor = _gtkWindow.getDisplay().getMonitor(0);

    //     return geometry.width;
    //     // return 1000;
    // }

    // uint displayHeight() {
    //     // auto display = Display.getDefault();
    //     // auto screen = display.getDefaultScreen();
    //     // return screen.getHeight();
    //     // return Screen.height();
    //     return 1000;
    // }

    Application app;
}
