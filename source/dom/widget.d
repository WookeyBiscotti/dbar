module dom.widget;

import gtk.Container;

class WidgetNode {
public:
    Container asContainer() {
        return null;
    }

    string name() const {
        return _name;
    }

    abstract void onVarsUpdated();

protected:
    string _name;
    WidgetNode _parent;
    WidgetNode[] _childs;
}
