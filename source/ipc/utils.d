module ipc.utils;

import std.process;
import std.file;
import std.path;

enum IPC_MAX_PACKAGE_SIZE = 8192;

string ipcSocketPath() {
    return "/tmp/dwd/" ~ instanceId() ~ ".sock";
}

string instanceId() {
    auto xdgSessionId = environment.get("XDG_SESSION_ID");
    if (xdgSessionId) {
        return xdgSessionId;
    } else {
        // This means that we have one daemon on all sessions
        return "null";
    }
}

void resetIpcSocket(string name) {
    mkdirRecurse(name.dirName());
    if (name.exists()) {
        name.remove();
    }
}
