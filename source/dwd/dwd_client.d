module dwd.dwd_client;

import ipc.utils;
import ipc.commands;

import std.socket;
import std.conv;
import std.json;
import std.logger;
import std.stdio;
import std.logger;

struct DWDClientConfig {
    bool debugLogs;
}

class DWDClient {
public:
    this(DWDClientConfig conf) {
        if (conf.debugLogs) {
            sharedLog = cast(shared) new FileLogger(stderr);
        } else {
            sharedLog = cast(shared) new NullLogger;
        }
    }

    BaseCmd.Response sendCommand(string cmdName, BaseCmd.Request cmd) {
        try {
            JSONValue jsReq = ["cmd": cmdName];
            cmd.dump(jsReq);
            JSONValue jsResp = parseJSON(sendStrCommand(jsReq.toString()));

            return makeResponse(cmdName, jsResp);
        } catch (Exception e) {
            error(e.msg);
        }

        return null;
    }

private:
    string sendStrCommand(string msg) {
        auto socket = new Socket(AddressFamily.UNIX, SocketType.STREAM);
        scope (exit)
            socket.close();

        socket.connect(new UnixAddress(ipcSocketPath()));
        socket.send(msg);

        char[IPC_MAX_PACKAGE_SIZE] buffer;
        auto received = socket.receive(buffer);

        return buffer[0 .. received].to!string;
    }
}
