module widgets.label;

import gtk.Widget;
import gtk.Label;
import gtk.Box;

import widgets.widget;
import utils;
import context;

import std.uuid;

import dyaml;

class LabelNode : WidgetNode {
public:
    this(Context ctx, WidgetNode parent, ref Node node) {
        super(ctx);
        _parent = parent;
        WidgetNode.parse(node);
        parse(node);
        constructGtkWidget();
        LabelNode.onVarsUpdated();
    }

    override Widget asWidget() {
        return _label;
    }

    final void constructGtkWidget() {
        _label = new Label(_context.resolve(_text));

        onVarsUpdated();
    }

    override void onVarsUpdated() {
        super.onVarsUpdated();

        _label.setText(_context.resolve(_text));
    }

private:
    void parse(ref Node node) {
        _text = grabDeps(node["text"].as!string);
    }

    Label _label;
    string _text;
}
