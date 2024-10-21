#!/bin/bash

cap_help_description() {
  cat <<EOF
  Shows help for the cap command line tool.
EOF
}

cap_help_help() {
  cap_help_description
  echo

  cat <<EOF
  The "help" command will display help for all the commands available for the
  cap command.

  Usage:
    cap help [COMMAND]

    COMMAND - optional parameter of command to show help for. If not command
      is provided then a list of all commands with a brief description will
      be shown.

  Example:
    $ cap help

    Commands:

    help  Shows help for the cap command line tool.
    md5   Calculates a combined MD5 checksum for one or more files.
EOF
}

cap_help() {
  echo

  # Check if a parameter was provided
  if [ "$#" -eq 0 ]; then
    cat <<EOF
  Usage: cap COMMAND ...

  Commands:
    The following subcommands are available.

  COMMAND
EOF

    # Directory containing the scripts
    CAP_COMMANDS_DIR="$CAP_INSTALL_PATH"/commands

    {
      # Loop through each script file in the directory
      for script in "$CAP_COMMANDS_DIR"/*.sh; do
        # Get the base name of the script (e.g., md5 for md5.sh)
        script_name=$(basename "$script" .sh)

        # Construct the function name
        description_function="cap_${script_name}_description"

        # Check if the function exists
        if declare -f "$description_function" > /dev/null; then
          printf '    %s:' "$script_name"

          # Call the function
          "$description_function"
        else
          echo "    Error:  Function $description_function not found in $script"
        fi
      done
    } | column -t -s ':'
  else
    # Retrieve the command name from the first parameter
    command_name=$1
    # Construct the function name
    help_function="cap_${command_name}_help"
    # Call the function
    "$help_function" | less -FX
  fi
  echo
}
