// module parser.window_info;

// import std.sumtype;
// import std.typecons;
// import std.conv;

// import dyaml;

// import parser.utils;
// import context;

// struct WindowNode
// {
//     this(Context ctx, string name, ref Node node)
//     {
//         this.name = name;
//         layer = layerFromNode(ctx, node["layer"]);
//         anchors = anchorsFromNode(ctx, node["anchors"]);
//         margins = marginsFromNode(ctx, node["margins"]);
//         keyboardMode = keyboardModeFromNode(ctx, node["keyboard_mode"]);
//         autoExclusiveMode = cast(bool)(ctx.resolve(getOrDefault(node, "auto_exclusive", "0"))
//                 .to!int);
//     }

//     string name;
//     Layer layer;
//     int[Edge.sizeof] anchors;
//     int[Edge.sizeof] margins;
//     KeyboardMode keyboardMode;
//     bool autoExclusiveMode;
// }

// enum Layer
// {
//     BACKGROUND,
//     BOTTOM,
//     TOP,
//     OVERLAY,
// }

// Layer layerFromNode(Context ctx, ref Node node)
// {
//     auto v = ctx.resolve(node.as!string);

//     //dfmt off
//     switch (v)
//     {
//     case "top": return Layer.TOP;
//     case "bg": return Layer.BACKGROUND;
//     case "bottom": return Layer.BOTTOM;
//     case "overlay": return Layer.OVERLAY;
//     default: return Layer.TOP;
//     }
//     //dfmt on
// }

// enum Edge
// {
//     LEFT,
//     RIGHT,
//     TOP,
//     BOTTOM,
// }

// int[Edge.sizeof] anchorsFromNode(Context ctx, ref Node node)
// {
//     int[Edge.sizeof] edges;
//     edges[0] = ctx.resolve(node[0].as!string).to!int;
//     edges[1] = ctx.resolve(node[1].as!string).to!int;
//     edges[2] = ctx.resolve(node[2].as!string).to!int;
//     edges[3] = ctx.resolve(node[3].as!string).to!int;

//     return edges;
// }

// int[Edge.sizeof] marginsFromNode(Context ctx, ref Node node)
// {
//     int[Edge.sizeof] margins;
//     margins[0] = ctx.resolveInWindowWidth(ctx.resolve(node[0].as!string));
//     margins[1] = ctx.resolveInWindowWidth(ctx.resolve(node[1].as!string));
//     margins[2] = ctx.resolveInWindowHeight(ctx.resolve(node[2].as!string));
//     margins[3] = ctx.resolveInWindowHeight(ctx.resolve(node[3].as!string));

//     return margins;
// }

// enum KeyboardMode
// {
//     NONE = 0,
//     EXCLUSIVE = 1,
//     DEMAND = 2,
// }

// KeyboardMode keyboardModeFromNode(Context ctx, ref Node node)
// {
//     auto v = ctx.resolve(node.as!string);

//     //dfmt off
//     switch (v)
//     {
//     case "none": return KeyboardMode.NONE;
//     case "exclusive": return KeyboardMode.EXCLUSIVE;
//     case "demand": return KeyboardMode.DEMAND;
//     default: return KeyboardMode.NONE;
//     }
//     //dfmt on
// }

// unittest
// {
//     Node root = Loader.fromString(`
// windows:
//   - name: mainbar
//     args:
//     layer: top # bg, top, bottom, overlay
//     anchors: [1, 1, 0, 0] # left, right, top, bottom
//     margins: [10%, 10, 10, 20%]
//     keyboard_mode: exclusive # none, exclusive, demand
//     auto_exclusive: 0
// `).load();

//     import std;

//     auto ctx = new Context;
//     foreach (pair; root["windows"].mapping)
//     {
//         auto window = WindowNode(ctx, pair.key, pair.value);
//     }
// }
