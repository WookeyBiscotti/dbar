module variables.pollvar;

import utils;
import context;
import variables.variable;

import dyaml;

import core.time;
import std.process;
import std.stdio;
import std.array;
import std.concurrency;
import core.thread;

class PollVariable : Variable {
    this(Context ctx, string name, ref Node node) {
        super(ctx, name, node);
        _command = getOrDefault(node, "command", "");
        _interval = parseDuration(getOrDefault(node, "interval", "1m"));
        _timeout = parseDuration(getOrDefault(node, "timeout", "1s"));
    }

    override void start() {
        import std.stdio;

        auto dg = () shared{
            while (true) {
                auto ps = pipeShell(_command);
                wait(ps.pid());
                auto rawValue = cast(char[])(ps.stdout.byChunk(4096).join);

                try {
                    setVariable(Loader.fromString(rawValue).load());
                } catch (Exception e) {
                    setVariable(Node(rawValue));
                }

                _ctx.updateVariable(name);
                Thread.getThis().sleep(_interval);
            }
        };

        spawn(dg);
    }

private:
    string _command;
    Duration _interval;
    Duration _timeout;
}
