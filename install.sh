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
  git clone --recurse-submodules https://github.com/lasseignelab/capture.git
  cd capture
  . configure.sh
fi
