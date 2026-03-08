#!/bin/sh
# Returns the window ID of the active terminal
. ~/.local/etc/terminal.conf

/usr/bin/python3 -c "
import Quartz
windows = Quartz.CGWindowListCopyWindowInfo(Quartz.kCGWindowListOptionOnScreenOnly, Quartz.kCGNullWindowID)
for name in '${TERMINALS}'.split():
    for w in windows:
        if name in str(w.get('kCGWindowOwnerName', '')):
            print(w['kCGWindowNumber'])
            exit()
" 2>/dev/null
