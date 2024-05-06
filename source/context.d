module context;

import std.string;
import std.array;
import std.conv;

import gtk.Application;

class Context {
    this(Application app) {
        this.app = app;
    }

    string resolve(string value) {
        if (value.startsWith("${") && value.endsWith("}")) {
            import core.stdc.stdlib;

            throw new Exception("Not implemented");
        } else {
            return value;
        }
    }

    int resolveInWindowHeight(string value) {
        auto resolved = resolve(value);

        if (resolved.endsWith("%")) {
            return resolved[0 .. $ - 1].to!int * displayHeight() / 100;
        } else {
            return resolved.to!int;
        }
    }

    int resolveInWindowWidth(string value) {
        auto resolved = resolve(value);

        if (resolved.endsWith("%")) {
            return resolved[0 .. $ - 1].to!int * displayWidth() / 100;
        } else {
            return resolved.to!int;
        }
    }

    uint displayWidth() {
        return 1000;
    }

    uint displayHeight() {
        return 1000;
    }

    Application app;
}
