#!/bin/bash

echo "Starting service..."

export DBUS_SESSION_BUS_ADDRESS=tcp:host=dbus,port=55884

python service.py

