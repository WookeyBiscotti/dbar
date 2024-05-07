module utils;

import gdk.Screen;
import gdk.MonitorG;

string[] getMonitorsPlugNames() {
    auto screen = Screen.getDefault();

    auto count = screen.getNMonitors();

    string[] result;
    foreach (i; 0 .. count) {
        result ~= screen.getMonitorPlugName(i);
    }

    return result;
}

MonitorG getMonitorFromPlugName(string name) {
    auto screen = Screen.getDefault();

    auto count = screen.getNMonitors();

    string[] result;
    foreach (i; 0 .. count) {
        if (screen.getMonitorPlugName(i) == name) {
            return screen.getDisplay().getMonitor(i);
        }
    }

    return null;
}
