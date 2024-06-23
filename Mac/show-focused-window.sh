#!/bin/bash

# Function to get the currently focused application name
get_focused_app() {
  osascript -e 'tell application "System Events" to get name of (processes where frontmost is true)'
}

# Function to log the current focused application to the console with a timestamp
log_focused_app() {
  local app_name=$(get_focused_app)
  local timestamp=$(date +"%Y-%m-%d %H:%M:%S.%3N")
  echo "$timestamp  $app_name"
}

# Main loop to continuously log the focused application
while true; do
  log_focused_app
  sleep 1  # Adjust the sleep duration as needed
done

