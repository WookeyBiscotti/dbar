module widgets.widget;

import std.uuid;
import gtk.Container;
import gtk.Widget;
import gtk.StyleContext;

import dyaml;
import utils;
import context;

class WidgetNode {
public:
    this(Context ctx) {
        _context = ctx;
    }

    Container asContainer() {
        return null;
    }

    Widget asWidget() {
        return null;
    }

    final string name() const {
        return _name;
    }

    final string resolve(string str) {
        return _context.resolve(str);
    }

    final string grabDeps(string str) {
        auto vars = _context.extractVariables(str);
        foreach (v; vars) {
            _context.addDependency(v, this);
        }

        return str;
    }

    final void parse(ref Node node) {
        _name = grabDeps(node.getOrDefault("name", randomUUID().toString()));
        _halign = grabDeps(node.getOrDefault("halign", "fill"));
        _valign = grabDeps(node.getOrDefault("valign", "fill"));
        _class = grabDeps(node.getOrDefault("class", ""));
    }

    void onVarsUpdated() {
        auto w = asWidget();

        auto ha = getAlign(_context.resolve(_halign));
        w.setHalign(ha);

        auto va = getAlign(_context.resolve(_valign));
        w.setValign(va);

        auto class_ = _context.resolve(_class);
        if (class_) {
            w.getStyleContext().addClass(class_);
        }
    }

protected:
    Context _context;
    string _name;
    string _halign;
    string _valign;
    string _class;

    WidgetNode _parent;
    WidgetNode[] _childs;
}
