module widgets.box;

import gtk.Widget;
import gtk.Box;
import gtk.Container;

import widgets.widget;
import widgets.parser;
import utils;
import context;

import std.uuid;
import std.conv;

import dyaml;

class BoxNode : WidgetNode {
public:
    this(Context ctx, WidgetNode parent, ref Node node) {
        super(ctx);
        _parent = parent;
        WidgetNode.parse(node);
        parse(node);
        BoxNode.onVarsUpdated();
    }

    final void constructGtkWidget() {
        auto oStr = _context.resolve(_orientation);
        GtkOrientation orientation;
        if (oStr == "v" || oStr == "vertical") {
            orientation = GtkOrientation.VERTICAL;
        } else {
            orientation = GtkOrientation.HORIZONTAL;
        }

        _box = new Box(orientation, _context.resolve(_padding).to!int);
    }

    override Widget asWidget() {
        return _box;
    }

    override Container asContainer() {
        return _box;
    }

    override void onVarsUpdated() {
        super.onVarsUpdated();

        _box.removeAll();
        foreach (i, c; _childs) {
            auto packing = _context.resolve(_childPacking[i]);
            if (packing == "start") {
                _box.packStart(c.asWidget(), false, false, 0);
            } else if (packing == "center") { //only one widget can be at center
                _box.setCenterWidget(c.asWidget());
            } else {
                _box.packEnd(c.asWidget(), false, false, 0);
            }
        }
    }

private:
    void parse(ref Node node) {
        _orientation = grabDeps(getOrDefault(node, "orientation", "h"));
        _padding = grabDeps(getOrDefault(node, "padding", "0"));

        constructGtkWidget();

        if (node.containsKey("childs") && node["childs"].type() == NodeType.sequence) {
            foreach (v; node["childs"].sequence) {
                auto pair = v.mapping.front();
                auto w = parseWidget(_context, this, pair.key.as!string, pair.value);
                _childs ~= w;
                auto packing = grabDeps(pair.value.getOrDefault("box_packing", "start"));

                if (packing != "start" && packing != "center" && packing != "end") {
                    throw new Exception("`box_packing` must be `start`, `center` or `end`");
                }
                _childPacking ~= packing;
            }
        }

        _box.showAll();
    }

    Box _box;
    string[] _childPacking;
    string _text;
    string _orientation;
    string _padding;
}
