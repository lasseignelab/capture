#!/bin/bash

cd ~/ || exit
mkdir -p bin
cd bin || exit
if [ -d capture ]; then
  cat <<EOF

The CAPTURE framework has already been installed. Execute the following
command to upgrade to the newest version.

$ cap update

EOF
else
  git clone --recurse-submodules https://github.com/lasseignelab/lab-framework.git

  # Check if $HOME/bin/capture is already in PATH
  if ! grep -q "\$HOME/bin/capture" ~/.bash_profile; then
    echo "Adding $HOME/bin/capture to PATH in .bash_profile"
    echo "export PATH=\"\$PATH:\$HOME/bin/capture\"" >> ~/.bash_profile
  else
    echo "$HOME/bin/capture is already in PATH"
  fi
fi
