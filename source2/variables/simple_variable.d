module variables.simple_variable;

import context;
import utils;

public import variables.variable;

import dyaml;

import std.sumtype;
import std.array;

class SimpleVariable : Variable {
public:
    this(Context contex, string name, ref Node node) {
        _ctx = contex;
        _name = name;
        if (node.containsKey("init")) {
            _value = node["init"];
        }
    }

    override string name() const shared {
        return _name;
    }

    override void start() {
    }

    override string getValue() shared {
        synchronized (this) {
            if (_value.type() == NodeType.sequence || _value.type() == NodeType.mapping) {
                return dump(_value);
            } else {
                auto res = _value.as!string;
                return res;
            }
        }
    }

    override string getValue(Path path) shared {
        try {
            synchronized (this) {
                auto value = _value;
                while (path.length) {
                    value = path[0].match!((string str) => value[str], (ulong idx) => value[idx]);
                    path = path[1 .. $];
                }
                if (value.isValid()) {
                    return value.as!string;
                }
            }
        } catch (Exception e) {
            // writeln(e);
        }
        return "null";
    }

    override void setValue(Node value) shared {
        synchronized (this) {
            _value = value;
        }
    }

    string[] dependsOn() const shared {

    }

protected:
    Context _ctx;
private:
    Node _value;
    immutable string _name;
}
