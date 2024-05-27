module gtk.gtk_service;

import gdk.Gdk;
import gtk.Application;
import gtk.ApplicationWindow;

import std.concurrency;
import core.time;
import core.atomic;

import gtk.messages;
import gtk.utils;
import gtk.types;

class GtkService {
public:
    this(Tid dwdThread) {
        import std.process;

        environment["GDK_BACKEND"] = "wayland";

        Gdk.setAllowedBackends("wayland");

        _application = new Application("org.gtkd.dwd", GApplicationFlags.FLAGS_NONE);
    }

    void run() {
        _isRunning = true;

        _application.addOnActivate(delegate void(GioApplication) {
            auto dlg = () shared{ workThread(); };
            _workThread = spawn(dlg);
        });

        _application.run([]);
    }

    void workThread() {
        while (_isRunning.atomicLoad()) {
            // dfmt off
            receiveTimeout(dur!"seconds"(5),
                (CreateWindow.Req msg) { send(_dwdThread, cast(shared) createWindow(msg)); },
                (GetMonitorSize.Req msg) { send(_dwdThread, getMonitorSize(msg)); },
            );
            // dfmt on
        }
    }

private:
    CreateWindow.Resp createWindow(CreateWindow.Req req) {
        import bindings.gtk_layer_shell;

        auto window = new ApplicationWindow(_application);
        auto gtkWindow = cast(GtkWindow*) window.getApplicationWindowStruct();
        gtk_layer_init_for_window(gtkWindow);

        gtk_layer_set_layer(gtkWindow, req.layer);
        gtk_layer_set_monitor(gtkWindow, getMonitorFromIdx(req.monitor).getMonitorGStruct());
        foreach (i; GtkEdge.GTK_LAYER_SHELL_EDGE_LEFT .. GtkEdge.GTK_LAYER_SHELL_EDGE_ENTRY_NUMBER) {
            gtk_layer_set_anchor(gtkWindow, i, req.anchors[i]);
        }

        foreach (i; GtkEdge.GTK_LAYER_SHELL_EDGE_LEFT .. GtkEdge.GTK_LAYER_SHELL_EDGE_ENTRY_NUMBER) {
            gtk_layer_set_margin(gtkWindow, i, req.margins[i]);
        }

        gtk_layer_set_keyboard_mode(gtkWindow, req.keyboardMode);

        gtk_layer_set_keyboard_interactivity(gtkWindow, req.keyboardInteractivity);
        if (req.autoExclusiveMode) {
            gtk_layer_auto_exclusive_zone_enable(gtkWindow);
        }

        window.setSizeRequest(req.size[0], req.size[1]);
        return CreateWindow.Resp(cast(void*) window);
    }

    GetMonitorSize.Resp getMonitorSize(GetMonitorSize.Req req) {
        auto monitor = getMonitorFromIdx(req.monitor);
        GdkRectangle geometry;
        monitor.getWorkarea(geometry);

        return GetMonitorSize.Resp([geometry.width, geometry.height]);
    }

    Tid _dwdThread;
    Tid _workThread;
    Application _application;
    bool _isRunning;
}
