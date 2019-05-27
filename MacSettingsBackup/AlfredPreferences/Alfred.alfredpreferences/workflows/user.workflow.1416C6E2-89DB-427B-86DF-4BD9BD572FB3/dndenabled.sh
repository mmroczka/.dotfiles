#!/bin/bash

val=$(defaults -currentHost read "${HOME}/Library/Preferences/ByHost/com.apple.notificationcenterui" doNotDisturb)
if [ "$val" = 0 ]
then
  echo -n "disabled"
else
  echo -n "enabled"
fi
