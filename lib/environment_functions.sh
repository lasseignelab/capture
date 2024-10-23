#!/bin/bash

cap_data_link() {
  # Verify the file/directory parameter has been passed in.
  target_path="$1"
  if [ -z "$target_path" ]; then
    echo "Error cap_data_link: incorrect number of parameters" >&2
    echo "Usage: cap_data_link <target_path>" >&2
    echo "Check environment file config/environments/$CAP_ENV.sh." >&2
    echo "See README for detailed help." >&2
    exit 1
  fi

  # Verify that the file/directory exists.
  if [ ! -e "$target_path" ]; then
    echo "Error cap_data_link: File or directory does not exist." >&2
    echo "Path: $target_path" >&2
    echo "Check environment file config/environments/$CAP_ENV.sh." >&2
    exit 1
  fi

  # Create a symlink to the file/directory in the project data path.
  if [ ! -d "$CAP_DATA_PATH" ]; then
    mkdir -p "$CAP_DATA_PATH"
  fi
  link_path="$CAP_DATA_PATH/$(basename "$target_path")"
  if [ ! -e "$link_path" ]; then
    ln -s "$target_path" "$link_path"
  fi
}
