module gtk.messages;

import gtk.types;

struct CreateWindow {
    struct Req {
        GtkLayer layer;
        int monitor;
        int[2] size;
        int[GtkEdge.sizeof] anchors;
        int[GtkEdge.sizeof] margins;
        GtkKeyboardMode keyboardMode;
        int keyboardInteractivity;
        bool autoExclusiveMode;
    }

    struct Resp {
        void* window;
    }
}

struct GetMonitorSize {
    struct Req {
        int monitor;
    }

    struct Resp {
        int[2] size;
    }
}
