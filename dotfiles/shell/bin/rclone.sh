#!/bin/bash
#
# Rclone.sh
#
# Script to initialize remote mounts.  Called from rclone.desktop autostart file.
#
# Author(s): Cody Buell
#
# Revisions: 2018.05.04 Initial framework.
#
# Requisite: 
#
# Resources: 
#
# Task List: 
#
# Usage: 

rclone mount Google:Notes /home/pbuell/GDrive/Notes &
rclone mount Google:Journal /home/pbuell/GDrive/Journal &
rclone mount Google:Codex /home/pbuell/GDrive/Codex &
