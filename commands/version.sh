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
  # Location where the CAPTURE framework was installed.
  cap_install_path=$(command -v cap)
  cap_install_dir=$(dirname "$cap_install_path")

  echo

  # Display the current version of CAPTURE.
  cd "$cap_install_dir"
  if current_tag=$(git describe --tags --abbrev=0 2>/dev/null); then
    echo "$current_tag"
  else
    echo "Unlabeled version."
  fi

  echo
}

