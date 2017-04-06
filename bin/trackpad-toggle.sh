#!/bin/bash

# $XMONAD_CONFIG_TOUCHPAD_DEVICE_NAME should be set in some script
# Ex: ~/.config/plasma-workspace/env/set_window_manager.sh (KDE)

touchpadDeviceId="$(xinput list | grep "$XMONAD_CONFIG_TOUCHPAD_DEVICE_NAME" | sed -r 's/^.*id=(\w+).*$/\1/')"
if [[ $touchpadDeviceId == '' ]] ; then
	notify-send "Your touch pad device ($XMONAD_CONFIG_TOUCHPAD_DEVICE_NAME) is not found in 'xinput list'"
	exit 1
fi

touchpadIsEnabled="$(xinput list-props "$touchpadDeviceId" | grep 'Device Enabled' | sed -r 's/^\s+Device Enabled.*(.)$/\1/')"
if [[ $touchpadIsEnabled = 1 ]] ; then
	xinput disable "$touchpadDeviceId"
else
	xinput enable "$touchpadDeviceId"
fi
