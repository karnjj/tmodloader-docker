#!/bin/sh

# If no worlds exist, don't bother sending any commands
ls /terraria/tModLoader/Worlds/*.wld >/dev/null || exit

tmux send-keys "$1" Enter
