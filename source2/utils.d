module source2.utils;

import gdk.Screen;
import gdk.MonitorG;

import gtk.c.types;

import core.time;
import std.conv;
import std.process;
import std.array;
import std.algorithm;
import std.string;
import std.concurrency;

import dyaml;
import core.interpolation;

string[] getMonitorsPlugNames() {
    auto screen = Screen.getDefault();
    auto count = screen.getNMonitors();

    string[] result;
    foreach (i; 0 .. count) {
        result ~= screen.getMonitorPlugName(i);
    }

    return result;
}

MonitorG getMonitorFromPlugName(string name) {
    auto screen = Screen.getDefault();

    auto count = screen.getNMonitors();

    foreach (i; 0 .. count) {
        if (screen.getMonitorPlugName(i) == name) {
            return screen.getDisplay().getMonitor(i);
        }
    }

    return null;
}

T getOrDefault(T)(ref Node node, string key, lazy T value) {
    return node.containsKey(key) ? node[key].as!T : value;
}

Duration parseDuration(string str) {
    if (str.endsWith("ms")) {
        return dur!"msecs"(str[0 .. $ - 2].to!int);
    } else if (str.endsWith("us")) {
        return dur!"usecs"(str[0 .. $ - 2].to!int);
    } else if (str.endsWith("s")) {
        return dur!"seconds"(str[0 .. $ - 1].to!int);
    } else if (str.endsWith("m")) {
        return dur!"minutes"(str[0 .. $ - 1].to!int);
    } else {
        return dur!"seconds"(str[0 .. $ - 1].to!int);
    }
}

GtkAlign getAlign(string a) {
    if (a == "fill") {
        return GtkAlign.FILL;
    } else if (a == "start") {
        return GtkAlign.START;
    } else if (a == "end") {
        return GtkAlign.END;
    } else if (a == "center") {
        return GtkAlign.CENTER;
    }

    return GtkAlign.BASELINE;
}

enum Edge {
    LEFT = 0,
    RIGHT = 1,
    TOP = 2,
    BOTTOM = 3,

    COUNT = 4,
}

enum KeyboardMode {
    NONE = 0,
    EXCLUSIVE = 1,
    DEMAND = 2,
}

enum Layer {
    TOP,
    BACKGROUND,
    BOTTOM,
    OVERLAY,
}

Layer layerFromString(string v) {
    switch (v) {
    case "top":
        return Layer.TOP;
    case "bg":
        return Layer.BACKGROUND;
    case "bottom":
        return Layer.BOTTOM;
    case "overlay":
        return Layer.OVERLAY;
    default:
        return Layer.TOP;
    }
}

KeyboardMode keyboardModeFromString(string v) {
    switch (v) {
    case "none":
        return KeyboardMode.NONE;
    case "exclusive":
        return KeyboardMode.EXCLUSIVE;
    case "demand":
        return KeyboardMode.DEMAND;
    default:
        return KeyboardMode.NONE;
    }
}

string dump(Node node) {
    if (node.isValid) {
        auto stream = new Appender!string();
        dumper.dump(stream, node);
        return stream.data();
    } else {
        return "null";
    }
}

void executeCmd(const string command, Duration timeout) {
    auto dg = () shared{ executeShell(command); };
    spawn(dg);
}

bool executableExist(string cmd) {
    return !!executeShell("command -v " ~ cmd).output;
}
