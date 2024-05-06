module widgets.label;

import gtk.Widget;
import gtk.Label;

import dom.widget;
import parser.utils;
import context;

import std.uuid;

import dyaml;

class LabelNode : WidgetNode {
public:
    this(Context ctx, WidgetNode parent, ref Node node) {
        _context = ctx;
        _parent = parent;
        parse(node);
        constructGtkWidget();
    }

    void constructGtkWidget() {
        _label = new Label(_context.resolve(_text));
        _parent.asContainer().add(_label);
    }

    override void onVarsUpdated() {
        _label.setText(_context.resolve(_text));
    }

private:
    void parse(ref Node node) {
        _name = node.getOrDefault("name", randomUUID().toString());
        _text = node["text"].as!string;
    }
    // private:
    Context _context;
    Label _label;
    string _text;
}
