module variables.listenvar;

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

class ListenVariable : Variable {
    this(Context ctx, string name, ref Node node) {
        super(ctx, name, node);
        _command = getOrDefault(node, "command", "");
    }

    override void start() {
        import std.stdio;

        auto dg = () shared{
            while (true) {
                try {
                    auto ps = pipeShell(_command);
                    foreach (line; ps.stdout.byLine()) {
                        try {
                            setVariable(Loader.fromString(line).load());
                        } catch (Exception e) {
                            setVariable(Node(line));
                        }
                        _ctx.updateVariable(name);
                    }
                } catch (Exception e) {
                    writeln(e);
                }
            }
        };

        spawn(dg);
    }

private:
    string _command;
}
