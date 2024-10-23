#!/bin/bash

cap_version_description() {
  cat <<EOF
  Displays the currently installed version of CAPTURE.
EOF
}

cap_version_help() {
  cap_version_description
  echo

  cat <<EOF
  The "version" command displays the current version of the CAPTURE framework.

  Usage:
    cap version

  Example:
    $ cap version
    v0.0.3
EOF
}

cap_version() {
  echo

  # Display the current version of CAPTURE.
  if ! cd "$CAP_INSTALL_PATH"; then
    echo "CAPTURE install directory is missing." >&2
    exit 1
  fi
  if current_tag=$(git describe --tags --abbrev=0 2>/dev/null); then
    echo "$current_tag"
  else
    echo "Unlabeled version."
  fi

  echo
}

