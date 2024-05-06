module dom.window;

import gtk.Application;
import gtk.ApplicationWindow;
import gtk_layer_shell;
import gtk.CssProvider;
import gtk.Container;

import dyaml;
import std.conv;

import context;
import parser.utils;
import dom.widget;
import widgets.label;

class WindowNode : WidgetNode {
public:
    this(Context ctx, string name, ref Node node) {
        _context = ctx;
        _name = name;
        parse(node);
    }

    override Container asContainer() {
        return _gtkWindow;
    }

    void show() {
        onVarsUpdated();
        _gtkWindow.showAll();
    }

    void hide() {
        _gtkWindow.hide();
    }

    override void onVarsUpdated() {
        auto gtkWindow = cast(GtkWindow*) _gtkWindow.getApplicationWindowStruct();

        auto layer = _context.resolve(_layer).layerFromString();
        gtk_layer_set_layer(gtkWindow, cast(GtkLayerShellLayer) layer);

        foreach (i; 0 .. 2) {
            gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowWidth(_anchors[i]).to!int);
        }
        foreach (i; 2 .. 4) {
            gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowHeight(_anchors[i]).to!int);
        }

        foreach (i; 0 .. 2) {
            gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowWidth(_margins[i]).to!int);
        }
        foreach (i; 2 .. 4) {
            gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) i,
                _context.resolveInWindowHeight(_margins[i]).to!int);
        }

        gtk_layer_set_keyboard_mode(gtkWindow,
            cast(GtkLayerShellKeyboardMode) _context.resolve(_keyboardMode)
            .keyboardModeFromString());

        gtk_layer_set_keyboard_interactivity(gtkWindow,
            _context.resolve(_keyboardInteractivity).to!int);

        if (_context.resolve(_autoExclusiveMode)) {
            gtk_layer_auto_exclusive_zone_enable(gtkWindow);
        }

        _gtkWindow.setSizeRequest(_context.resolveInWindowWidth(_size[0])
                .to!int, _context.resolveInWindowHeight(_size[1]).to!int);
    }

    void setStyleProvider(CssProvider provider, int priority) {
        _gtkWindow.getStyleContext().addProvider(provider, priority);
    }

private:
    void constructGtkWindow() {
        _gtkWindow = new ApplicationWindow(_context.app);
        auto gtkWindow = cast(GtkWindow*) _gtkWindow.getApplicationWindowStruct();

        gtk_layer_init_for_window(gtkWindow);
    }

    void parse(ref Node node) {
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
                if (pair.key.as!string == "label") {
                    auto label = new LabelNode(_context, this, pair.value);
                    _childs ~= label;
                }
            }

        }
        // if (widget.type() == NodeType.string) {
        //     _widget = widget.as!string;
        // } else {

        // }
    }
    // private:
    Context _context;
    ApplicationWindow _gtkWindow;
    string _layer;
    string[2] _size;
    string[Edge.sizeof] _anchors;
    string[Edge.sizeof] _margins;
    string _keyboardMode;
    string _keyboardInteractivity;
    string _autoExclusiveMode;
    string _widget;
}
