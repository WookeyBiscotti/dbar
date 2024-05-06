// module dom.window1;

// import gtk.Application;
// import gtk.ApplicationWindow;
// import gtk.Label;
// import gtk_layer_shell;

// import parser.window_info;

// class Window : ApplicationWindow
// {
// public:
//     this(Application app, WindowNode wi)
//     {
//         super(app);
//         auto gtkWindow = cast(GtkWindow*) this.getApplicationWindowStruct();

//         gtk_layer_init_for_window(gtkWindow);

//         gtk_layer_set_layer(gtkWindow, cast(GtkLayerShellLayer) wi.layer);

//         gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) 0, wi.anchors[0]);
//         gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) 1, wi.anchors[1]);
//         gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) 2, wi.anchors[2]);
//         gtk_layer_set_anchor(gtkWindow, cast(GtkLayerShellEdge) 3, wi.anchors[3]);

//         gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) 0, wi.margins[0]);
//         gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) 1, wi.margins[1]);
//         gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) 2, wi.margins[2]);
//         gtk_layer_set_margin(gtkWindow, cast(GtkLayerShellEdge) 3, wi.margins[3]);

//         if (wi.autoExclusiveMode)
//         {
//             gtk_layer_auto_exclusive_zone_enable(gtkWindow);
//         }

//         // add(new Label("Hello World"));

//         showAll();
//     }
// }
