module context;

import std.string;
import std.array;
import std.conv;
import std.regex;
import core.thread;

import gtk.Application;
import gtk.gtk_layer_shell;
import gtk.CssProvider;
import gtk.StyleContext;

import gdk.Display;
import gdk.Screen;
import gdk.MonitorG;
import gdk.Threads;

import widgets.widget;
import widgets.window;

import variables.variable;
import variables.pollvar;
import variables.listenvar;

import core.interpolation;

import utils;

import dyaml;

extern (C) nothrow static int threadIdleProcess(void* ctxPtr) {
    try {
        auto ctx = cast(Context) ctxPtr;
        string[] names;
        synchronized (ctx) {
            names = ctx._pendingUpdatedVariable;
            ctx._pendingUpdatedVariable = [];
        }
        foreach (name; names) {
            auto ws = ctx._dependency.require(name, new WidgetNode[string]);
            foreach (WidgetNode w; ws) {
                w.onVarsUpdated();
            }
        }
    } catch (Throwable t) {
    }
    return 0;
}

final class Context {
    this(Application app, string configPath, string cssPath) {
        _application = app;
        _configPath = configPath;

        auto provider = new CssProvider;
        provider.loadFromPath("/home/alex/.config/waybar/style.css");
        StyleContext.addProviderForScreen(Screen.getDefault(), provider,
            STYLE_PROVIDER_PRIORITY_APPLICATION);

        auto root = Loader.fromFile("dbar.yaml").load();

        if (root.containsKey("vars") && root["vars"].type() == NodeType.mapping) {
            foreach (pair; root["vars"].mapping) {
                auto var = new Variable(this, pair.key.as!string, pair.value);
                _variables[pair.key.as!string] = var;
            }
        }

        if (root.containsKey("pollvars") && root["pollvars"].type() == NodeType.mapping) {
            foreach (pair; root["pollvars"].mapping) {
                auto var = new PollVariable(this, pair.key.as!string, pair.value);
                _variables[pair.key.as!string] = var;
            }
        }

        if (root.containsKey("listenvars") && root["listenvars"].type() == NodeType.mapping) {
            foreach (pair; root["listenvars"].mapping) {
                auto var = new ListenVariable(this, pair.key.as!string, pair.value);
                _variables[pair.key.as!string] = var;
            }
        }

        foreach (pair; root["windows"].mapping) {
            auto window = new WindowNode(this, pair.key.as!string, pair.value);
            _windows[pair.key.as!string] = window;
            window.show();
        }
        // window.setStyleProvider(provider, STYLE_PROVIDER_PRIORITY_APPLICATION);
        // Screen.getDefault().
        StyleContext.addProviderForScreen(Screen.getDefault(), provider,
            STYLE_PROVIDER_PRIORITY_APPLICATION);

        foreach (v; _variables) {
            v.start();
        }
    }

    void updateVariable(string name) {
        synchronized (this) {
            _pendingUpdatedVariable ~= name;
            if (_pendingUpdatedVariable.length == 1) {
                gdk.Threads.threadsAddIdle(&threadIdleProcess, cast(void*) this);
            }
        }
    }

    void addDependency(string varName, WidgetNode widget) {
        _dependency.require(varName, new WidgetNode[string])[widget.name()] = widget;
    }

    auto app() {
        return _application;
    }

    string resolveOrDefault(ref Node node, string key, string value) {
        return resolve(node.getOrDefault(key, value));
    }

    string resolve(ref Node node, string key, string value) {
        return resolve(node.getOrDefault(key, value));
    }

    string[] extractVariables(string value) {
        auto inserts = exctractVarInsert(value);

        string[] results;
        foreach (ref i; inserts) {
            results ~= extractVarName(i.value);
        }

        return results;
    }

    string resolve(string value) {
        auto inserts = exctractVarInsert(value);

        foreach_reverse (ref i; inserts) {
            value = value[0 .. i.start] ~ variableValue(i.value) ~ value[i.end .. $];
        }

        return value;
    }

    int resolveInWindowHeight(string value, int displayHeight) {
        auto resolved = resolve(value);

        if (resolved.endsWith("%")) {
            return resolved[0 .. $ - 1].to!int * displayHeight / 100;
        } else {
            return resolved.to!int;
        }
    }

    int resolveInWindowWidth(string value, int displayWidth) {
        auto resolved = resolve(value);

        if (resolved.endsWith("%")) {
            return resolved[0 .. $ - 1].to!int * displayWidth / 100;
        } else {
            return resolved.to!int;
        }
    }

private:
    string variableValue(string str) {
        if (str.length) {
            auto varName = extractVarName(str);
            auto left = str[varName.length .. $];
            Path path;
            do {
                left = extractPath(left, path);
            }
            while (left.length);

            if (auto variable = varName in _variables) {
                return _variables[varName].value(path);
            } else {
                return "Not found";
            }
        }

        return "";
    }

    string extractVarName(string str) {
        if (!str.length) {
            return str;
        }
        foreach (i, c; str) {
            if (c == '.' || c == '[') {
                return str[0 .. i];
            }
        }

        return str;
    }

    string extractPath(string str, ref Path path) {
        if (!str.length) {
            return str;
        }
        if (str[0] == '.') {
            str = str[1 .. $];
            foreach (i, c; str) {
                if (c == '.' || c == '[') {
                    path ~= PathElement(str[0 .. i]);

                    return str[i .. $];
                }
            }
            path ~= PathElement(str);

            return "";
        } else if (str[0] == '[') {
            str = str[1 .. $];
            if (!str.length) {
                throw new Exception("Wrong variable format");
            }

            if (str[0] >= '0' && str[0] <= '9') {
                foreach (i, c; str) {
                    if (c == ']') {
                        path ~= PathElement(str[0 .. i].to!ulong);

                        return str[i + 1 .. $];
                    } else if (str[1] < '0' || str[1] > '9') {
                        throw new Exception("Wrong variable format");
                    }
                }
            }
        }

        throw new Exception("Wrong variable format");
    }

    struct VarInsert {
        ulong start;
        ulong end;
        string value;
    }

    VarInsert[] exctractVarInsert(string value) {
        import std.conv;

        VarInsert[] inserts;

        ulong variableStart = 0;
        char stringStart = 0;
        char prevChar = 0;
        foreach (idx, c; value) {
            if (c == '`' || c == '\'' || c == '"') {
                if (prevChar != '\\') {
                    if (!!stringStart) {
                        if (stringStart == c) {
                            stringStart = 0;
                        }
                    } else {
                        stringStart = c;
                    }
                }
            } else if (c == '{') {
                if (prevChar == '$') {
                    if (!stringStart) {
                        if (!!variableStart) {
                            throw new Exception(i"Error in variable: $(value) in pos $(idx)".text);
                        }
                        variableStart = idx;
                    }
                }
            } else if (c == '}') {
                if (!stringStart) {
                    if (!variableStart) {
                        throw new Exception(i"Error in variable: $(value) in pos $(idx)".text);
                    }
                    inserts ~= VarInsert(variableStart - 1, idx + 1, value[variableStart + 1 .. idx]);

                    variableStart = idx;
                }
            }
            prevChar = c;
        }

        return inserts;
    }

    Application _application;

    string _configPath;

    WidgetNode[string][string] _dependency;
    WindowNode[string] _windows;

    Variable[string] _variables;

    string[] _pendingUpdatedVariable;
}

private string pe(string v) {
    import std;

    writeln(v);

    return v;
}

unittest {
    auto ctx = new Context(null);

    // assert("qwe" == ctx.resolve("qwe"));
    assert(pe("qwe") == pe(ctx.resolve(`qwe${qwe123.qwe.123["${}"]qwe}`)));
}
