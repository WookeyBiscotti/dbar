module ipc.commands;

import std.json;
import std.algorithm;
import std.conv;

import core.interpolation;

import context;

struct BaseCmd {
    class Package {
        final JSONValue create() const {
            auto js = JSONValue.emptyObject;
            js.object["cmd"] = name();
            createImpl(js);

            return js;
        }

        final bool parse(in JSONValue js) nothrow {
            try {
                if (js["cmd"].str != name()) {
                    return false;
                }
                return parseImpl(js);
            } catch (Exception e) {
                return false;
            }
        }

        void createImpl(ref JSONValue js) const {
        }

        bool parseImpl(in JSONValue js) {
            return true;
        }

        abstract string name() const nothrow;
    }

    class Request : Package {
        abstract Response makeResponse();

        abstract void process(Context ctx);
    }

    class Response : Package {
        final override void createImpl(ref JSONValue js) const {
            js.object["msg"] = msg();
        }

        abstract string msg() const nothrow;
    }
}

struct PingCmd {
    class Req : BaseCmd.Request {
        this(string[]) {
        }

        override string name() const nothrow {
            return PingCmd.name();
        }

        override BaseCmd.Response makeResponse() {
            return new PingCmd.Resp();
        }

        override void process(Context) {
            // do nothing
        }
    }

    class Resp : BaseCmd.Response {
        this() {
        }

        this(string msg) {
            _msg = msg;
        }

        override string msg() const nothrow {
            return _msg;
        }

        override string name() const nothrow {
            return PingCmd.name();
        }

        private string _msg;
    }

    static string name() nothrow {
        return "ping";
    }
}

BaseCmd.Request makeRequest(string name, string[] args) {
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
