#!/bin/bash

# Check if $HOME/bin/capture is already in PATH
if ! grep -q "\$HOME/bin/capture" ~/.bash_profile; then
  echo "Adding $HOME/bin/capture to PATH in .bash_profile"
  echo "export PATH=\"\$PATH:\$HOME/bin/capture\"" >> ~/.bash_profile
else
  echo "$HOME/bin/capture is already in PATH"
fi

# Check if cap_completion is configured.
if ! grep -q "cap_completion.sh" ~/.bash_profile; then
  echo "Adding CAPTURE tab completion to .bash_profile"
  echo ". \$HOME/bin/capture/cap_completion.sh" >> ~/.bash_profile
else
  echo "CAPTURE tab completion is already configured."
fi
