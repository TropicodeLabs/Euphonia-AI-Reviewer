#!/bin/sh

# Define the path to the Custom-Generated.xcconfig file
CONFIG_FILE="macos/Flutter/ephemeral/Custom-Generated.xcconfig"

# Create the file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  mkdir -p "$(dirname "$CONFIG_FILE")"
  touch "$CONFIG_FILE"
fi

# Add the MACOSX_DEPLOYMENT_TARGET setting to the file
echo 'MACOSX_DEPLOYMENT_TARGET = 10.15' > "$CONFIG_FILE"
