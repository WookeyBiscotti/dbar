module parser.utils;

import dyaml;

import core.time;

import std.conv;
import std.array;
import std.algorithm;
import std.string;

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

enum Edge {
    LEFT,
    RIGHT,
    TOP,
    BOTTOM,
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
