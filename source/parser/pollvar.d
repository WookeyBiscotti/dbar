module parser.pollvar;

import parser.utils;
import context;

import dyaml;

import core.time;

struct PollVar
{
    this(Context ctx, string name, ref Node node)
    {
        this.name = name;
        command = getOrDefault(node, "command", "");
        interval = parseDuration(getOrDefault(node, "interval", "1m"));
        timeout = parseDuration(getOrDefault(node, "timeout", "1s"));
    }

    string name;
    string command;
    Duration interval;
    Duration timeout;
}
