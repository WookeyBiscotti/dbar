module gtk.utils;

import gdk.Screen;
import gdk.MonitorG;

import gtk.c.types;

MonitorG getMonitorFromIdx(int idx) {
    auto screen = Screen.getDefault();
    return screen.getDisplay().getMonitor(idx);
}
