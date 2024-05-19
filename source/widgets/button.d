module widgets.button;

import gtk.Widget;
import gtk.Button;

import widgets.widget;
import utils;
import context;

import std.uuid;
import core.time;

import dyaml;

class ButtonNode : WidgetNode {
public:
    this(Context ctx, WidgetNode parent, ref Node node) {
        super(ctx);
        _parent = parent;
        WidgetNode.parse(node);
        parse(node);
        constructGtkWidget();
        ButtonNode.onVarsUpdated();
    }

    override Widget asWidget() {
        return _button;
    }

    final void constructGtkWidget() {
        _button = new Button(_context.resolve(_text));

        onVarsUpdated();
    }

    override void onVarsUpdated() {
        super.onVarsUpdated();

        _button.setLabel(_context.resolve(_text));
        _button.addOnClicked((Button) {
            executeCmd(_context.resolve(_onClick), dur!"seconds"(1));
        });
    }

private:
    void parse(ref Node node) {
        _text = grabDeps(node["text"].as!string);
        _onClick = grabDeps(node.getOrDefault("onclick", ""));
    }

    Button _button;
    string _text;
    string _onClick;
}
