module dwd.dwd;

import std.path;
import std.getopt;
import std.process;
import std.socket;
import std.conv;
import std.stdio;
import std.json;
import std.algorithm;

import core.time;
import core.interpolation;

import ipc.utils;
import ipc.commands;

struct DWDConfig {
    string applicationPath;
    string configPath;
    bool debugLogs;
}

struct Paths {
    string application;
    string config;
    string log;
    string ipc;
}

class DWD {
public:
    this(string[] args) {
        // _applicationPath = args[0];
        // getopt(args, // 
        //     "c|config", &_paths.config, //
        //     "d|daemon", &_paths.config, //
        //     );
    }

    void run() {
        _isRunning = true;
        ipcThread();
    }

    string ping() const {
        return "Pong";
    }

    string kill() {
        _isRunning = false;

        return "Daemon is killed";
    }

private:

    void ipcThread() {
        auto listener = new Socket(AddressFamily.UNIX, SocketType.STREAM);
        scope (exit)
            listener.close();

        resetIpcSocket(ipcSocketPath());
        listener.bind(new UnixAddress(ipcSocketPath()));
        listener.listen(16);

        auto readSet = new SocketSet();
        Socket[] connectedClients;
        while (_isRunning) {
            readSet.reset();
            readSet.add(listener);

            foreach (Socket client; connectedClients) {
                readSet.add(client);
            }

            if (!Socket.select(readSet, null, null)) {
                continue;
            }

            foreach (ref Socket client; connectedClients) {
                if (!readSet.isSet(client)) {
                    continue;
                }

                char[IPC_MAX_PACKAGE_SIZE] buffer;
                auto got = client.receive(buffer);
                if (!got) {
                    client.shutdown(SocketShutdown.BOTH);
                    client.close();
                    client = null;
                    continue;
                }

                client.send(processIpcStr(buffer[0 .. got].to!string));
            }
            connectedClients = connectedClients.remove!(c => c is null, SwapStrategy.unstable);

            if (!readSet.isSet(listener)) {
                continue;
            }

            auto newSocket = listener.accept();
            connectedClients ~= newSocket;
        }

        foreach (Socket client; connectedClients) {
            client.close();
        }
    }

    string processIpcStr(string cmd) {
        try {
            auto js = parseJSON(cmd);
            auto req = makeRequest(js["cmd"].str, js);
            JSONValue jsResp = ["cmd": js["cmd"].str];
            req.process(this).dump(jsResp);

            return jsResp.toString();
        } catch (Exception e) {
            writeln(e);
        }

        return "";
    }

    string processIpc(Cmd)(string raw) {
        // try
    }

    bool _isRunning = true;
    Paths _paths;
}
