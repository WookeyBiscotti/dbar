module pollvars;

import parser.pollvar;

import core.time;

import std.container.rbtree;
import context;

class PollVars
{
public:
    this(Context ctx, PollVar[] vars)
    {
    }

private:
    PollVar[] _vars;
}
