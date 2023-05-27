#!/usr/bin/env bash

echo "stop hass"
sudo systemctl stop hass
echo "stop zwave"
sudo systemctl stop zwave
echo "stop mqtt"
sudo systemctl stop mqtt
echo "stop whisper"
sudo systemctl stop whisper
echo "stop piper"
sudo systemctl stop piper
echo "stop nginx"
sudo systemctl stop nginx
sleep 5
echo "start nginx"
sudo systemctl start nginx
echo "start whisper"
sudo systemctl start whisper
echo "start piper"
sudo systemctl start piper
echo "start mqtt"
sudo systemctl start mqtt
echo "start zwave"
sudo systemctl start zwave
echo "start hass"
sudo systemctl start hass

