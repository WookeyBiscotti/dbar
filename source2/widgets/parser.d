module widgets.parser;

import widgets.widget;
import context;

import widgets.label;
import widgets.box;
import widgets.button;

import dyaml;

WidgetNode parseWidget(Context ctx, WidgetNode parent, string name, ref Node node) {
    if (name == "label") {
        return new LabelNode(ctx, parent, node);
    } else if (name == "box") {
        return new BoxNode(ctx, parent, node);
    } else if (name == "button") {
        return new ButtonNode(ctx, parent, node);
    }

    return null;
}
