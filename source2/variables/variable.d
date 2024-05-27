module variables.variable;

import dyaml;
import context;
import utils;

import std.sumtype;
import std.array;

alias PathElement = SumType!(ulong, string);
alias Path = PathElement[];

interface Variable {
public:
    void start();

    string name() const shared;

    string[] dependsOn() const shared;

    string getValue() const shared;
    string getValue(Path path) const shared;

    void setValue(Node value) shared;
    void setValue(Path path, Node value) shared;
}
