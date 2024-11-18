#!/bin/bash

# Location where the CAPTURE framework was installed.
cap_install_fullpath=$(command -v cap)
CAP_INSTALL_PATH=$(dirname "$cap_install_fullpath")

# Load commands
for file in "$CAP_INSTALL_PATH"/lib/functions/*.sh; do
    # shellcheck disable=SC1090
    source "$file"
done
