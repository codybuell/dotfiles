#!/bin/sh

sleep 20

conky -c ~/.conky/modules/cpu.conky &
conky -c ~/.conky/modules/filesystem.conky &
#conky -c ~/.conky/modules/time.conky &
#conky -c ~/.conky/modules/battery.conky &
#conky -c ~/.conky/modules/memory.conky &
