#!/bin/sh
CONFIG_FILE="macos/Flutter/ephemeral/Flutter-Generated.xcconfig"
CUSTOM_CONFIG_FILE="macos/Flutter/ephemeral/Custom-Generated.xcconfig"

if ! grep -q "#include \"$CUSTOM_CONFIG_FILE\"" "$CONFIG_FILE"; then
  echo "#include \"$CUSTOM_CONFIG_FILE\"" >> "$CONFIG_FILE"
fi
