#!/bin/bash

# @raycast.schemaVersion 1
# @raycast.title Open Finder
# @raycast.mode silent
# @raycast.icon 📁

osascript -e '
tell application "Finder"
    if (count of windows) is 0 then
        make new Finder window
    end if
    activate
end tell
'
