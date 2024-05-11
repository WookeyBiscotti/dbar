module variables.variable;

import dyaml;
import context;
import utils;

import std.sumtype;
import std.array;

alias PathElement = SumType!(ulong, string);
alias Path = PathElement[];

class Variable {
public:
    this(Context contex, string name, ref Node node) {
        _ctx = contex;
        _name = name;
        if (node.containsKey("init")) {
            _value = node["init"];
        }
    }

    final string name() const {
        return _name;
    }

    string value() {
        synchronized (this) {
            if (_value.type() == NodeType.sequence || _value.type() == NodeType.mapping) {
                return dump(_value);
            } else {
                auto res = _value.as!string;
                return res;
            }
        }
    }

    void start() {
    }

    string value(Path path) {
        import std.stdio;

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

    void setVariable(Node value) {
        synchronized (this) {
            _value = value;
        }
    }

private:
    Node _value;
protected:
    Context _ctx;
    string _name;
}
