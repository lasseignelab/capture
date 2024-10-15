#!/bin/bash

cap_update_description() {
  cat <<EOF
  Updates the CAPTURE framework to the latest version.
EOF
}

cap_update_help() {
  cap_update_description
  echo

  cat <<EOF
  The "update" command updates CAPTURE to the latest version with all the
  newest features.

  Usage:
    cap update

  Example:
    $ cap update

    Switched to branch 'main'
    From https://github.com/lasseignelab/capture
     * branch            main       -> FETCH_HEAD
    Already up-to-date.

    Already on 'main'
    From https://github.com/lasseignelab/project-template
     * branch            main       -> FETCH_HEAD
    Already up-to-date.

    CAPTURE updated to version v0.0.3.
EOF
}

cap_update() {
  # Location where the CAPTURE framework was installed.
  cap_install_path=$(command -v cap)
  cap_install_dir=$(dirname "$cap_install_path")

  echo

  # Retrieve the current version of the CAPTURE framework.
  cd "$cap_install_dir"
  git checkout main
  git pull origin main

  # Retrieve the current project template for `cap new`.
  echo
  cd project-template
  git checkout main
  git pull origin main

  echo

  # Display the current version of CAPTURE.
  cd ..
  if current_tag=$(git describe --tags --abbrev=0 2>/dev/null); then
    echo "CAPTURE updated to version $current_tag."
  else
    echo "CAPTURE updated to an unlabeled version."
  fi

  echo
}
