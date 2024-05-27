module ipc.commands;

import std.json;
import std.algorithm;
import std.conv;

import core.interpolation;

import dwd.dwd;

struct BaseCmd {
    class Request {
        abstract void dump(ref JSONValue js) const;

        abstract Response process(DWD dwd);
    }

    class Response {
        abstract void dump(ref JSONValue js) const;

        abstract string msg() const nothrow;
    }
}

struct PingCmd {
    class Req : BaseCmd.Request {
        this(string[]) {
        }

        this(in JSONValue) {
        }

        override void dump(ref JSONValue js) const {
        }

        override BaseCmd.Response process(DWD dwd) {
            return new PingCmd.Resp(dwd.ping());
        }
    }

    class Resp : BaseCmd.Response {
        this(string msg) {
            _msg = msg;
        }

        this(in JSONValue js) {
            _msg = js["msg"].str;
        }

        override void dump(ref JSONValue js) const {
            js["msg"] = _msg;
        }

        override string msg() const nothrow {
            return _msg;
        }

        private string _msg;
    }

    static string name() nothrow {
        return "ping";
    }
}

struct KillCmd {
    class Req : BaseCmd.Request {
        this(string[]) {
        }

        this(in JSONValue) {
        }

        override void dump(ref JSONValue js) const {
        }

        override BaseCmd.Response process(DWD dwd) {
            return new KillCmd.Resp(dwd.kill());
        }
    }

    class Resp : BaseCmd.Response {
        this(string msg) {
            _msg = msg;
        }

        this(in JSONValue js) {
            _msg = js["msg"].str;
        }

        override void dump(ref JSONValue js) const {
            js["msg"] = _msg;
        }

        override string msg() const nothrow {
            return _msg;
        }

        private string _msg;
    }

    static string name() nothrow {
        return "kill";
    }
}

BaseCmd.Request makeRequest(Args...)(string name, Args args) {
    mixin(makeMixinReqFactory());

    return null;
}

private string makeMixinReqFactory() {
    string result;

    enum auto cmds = [__traits(allMembers, ipc.commands)].filter!(s => s != "BaseCmd"
                && s.endsWith("Cmd"));
    foreach (c; cmds) {
        if (result.length) {
            result ~= "else ";
        }
        result ~= i"if($(c).name() == name) { return new $(c).Req(args);}".text;
    }

    return result;
}

BaseCmd.Response makeResponse(Args...)(string name, Args args) {
    mixin(makeMixinRespFactory());

    return null;
}

private string makeMixinRespFactory() {
    string result;

    enum auto cmds = [__traits(allMembers, ipc.commands)].filter!(s => s != "BaseCmd"
                && s.endsWith("Cmd"));
    foreach (c; cmds) {
        if (result.length) {
            result ~= "else ";
        }
        result ~= i"if($(c).name() == name) { return new $(c).Resp(args);}".text;
    }

    return result;
}
