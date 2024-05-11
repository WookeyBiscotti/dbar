module widgets.window;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk.CssProvider;
import gtk.Container;
import gdk.Display;
import gtk.Widget;
import gdk.MonitorG;
import gtk.gtk_layer_shell;

import dyaml;
import std.conv;

import context;
import utils;
import widgets.widget;
import widgets.label;
import widgets.parser;
import utils;

class WindowNode : WidgetNode {
public:
    this(Context ctx, string name, ref Node node) {
        super(ctx);
        _name = name;
        parse(node);
        WindowNode.onVarsUpdated();
    }

    override Container asContainer() {
        return _gtkWindow;
    }

    override Widget asWidget() {
        return _gtkWindow;
    }

    void show() {
        _gtkWindow.showAll();
    }

    void hide() {
        _gtkWindow.hide();
    }

    override void onVarsUpdated() {
        super.onVarsUpdated();

        auto gtkWindow = cast(GtkWindow*) _gtkWindow.getApplicationWindowStruct();

        auto layer = _context.resolve(_layer).layerFromString();
        gtk_layer_set_layer(gtkWindow, cast(GtkLayerShellLayer) layer);

        auto monitorIdx = _context.resolve(_monitor).to!int;
        auto monitor = getMonitorFromIdx(monitorIdx);
        gtk_layer_set_monitor(gtkWindow, monitor.getMonitorGStruct());
        GdkRectangle geometry;
        monitor.getWorkarea(geometry);

        foreach (i; 0 .. 2) {
            gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowWidth(_anchors[i], geometry.width).to!int);
        }
        foreach (i; 2 .. 4) {
            gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowHeight(_anchors[i], geometry.height).to!int);
        }

        foreach (i; 0 .. 2) {
            gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowWidth(_margins[i], geometry.width).to!int);
        }
        foreach (i; 2 .. 4) {
            gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowHeight(_margins[i], geometry.height).to!int);
        }

        gtk_layer_set_keyboard_mode(gtkWindow,
            cast(GtkLayerShellKeyboardMode) _context.resolve(_keyboardMode)
            .keyboardModeFromString());

        gtk_layer_set_keyboard_interactivity(gtkWindow,
            _context.resolve(_keyboardInteractivity).to!int);

        if (_context.resolve(_autoExclusiveMode).to!int) {
            gtk_layer_auto_exclusive_zone_enable(gtkWindow);
        }

        _gtkWindow.setSizeRequest(_context.resolveInWindowWidth(_size[0],
                geometry.width).to!int, _context.resolveInWindowHeight(_size[1],
                geometry.height).to!int);
    }

    void setStyleProvider(CssProvider provider, int priority) {
        _gtkWindow.getStyleContext().addProvider(provider, priority);
    }

private:
    void constructGtkWindow() {
        _gtkWindow = new ApplicationWindow(_context.app);
        auto gtkWindow = cast(GtkWindow*) _gtkWindow.getApplicationWindowStruct();

        gtk_layer_init_for_window(gtkWindow);
        gtk_layer_set_layer(gtkWindow, cast(GtkLayerShellLayer) 0);
    }

    void parse(ref Node node) {
        _monitor = node.getOrDefault("monitor", getMonitorsPlugNames()[0]);

        _layer = node["layer"].as!string;

        auto size = node["size"];
        _size = [size[0].as!string, size[1].as!string];

        auto anchors = node["anchors"];
        _anchors = [
            anchors[0].as!string, anchors[1].as!string,
            anchors[2].as!string, anchors[3].as!string,
        ];

        auto margins = node["margins"];
        _margins = [
            margins[0].as!string, margins[1].as!string,
            margins[2].as!string, margins[3].as!string,
        ];

        _keyboardMode = getOrDefault(node, "keyboard_mode", "none");

        _keyboardInteractivity = getOrDefault(node, "keyboard_interactivity", "0");

        _autoExclusiveMode = getOrDefault(node, "auto_exclusive", "0");

        constructGtkWindow();

        auto widget = node["widget"];
        if (widget.type() == NodeType.mapping) {
            foreach (pair; widget.mapping) {
                auto w = parseWidget(_context, this, pair.key.as!string, pair.value);
                _gtkWindow.add(w.asWidget());
                _childs ~= w;
            }
        }
    }

    ApplicationWindow _gtkWindow;

    string _layer;
    string _monitor;
    string[2] _size;
    string[Edge.sizeof] _anchors;
    string[Edge.sizeof] _margins;
    string _keyboardMode;
    string _keyboardInteractivity;
    string _autoExclusiveMode;
}
