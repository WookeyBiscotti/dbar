module parser.label_info;

import parser.utils;
import context;

import dyaml;

struct LabelInfo
{
    string text;
    string name;

    this(Context ctx, string name, ref Node node)
    {
        this.text = getOrDefault(node, "text", "");
    }
}
