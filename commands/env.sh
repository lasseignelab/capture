#!/bin/bash

cap_env_description() {
  cat <<EOF
  Displays CAPTURE environment variables.
EOF
}

cap_env_help() {
  cap_env_description
  echo

  cat <<EOF
  The "env" command displays a list of all the CAPTURE environment variables
  along with their values. File and path values are displayed with full
  paths. This command must be executed from the project root directory.

  Usage:
    cap env

    Options:

    -e,--environment
               Specifies the environment to show variables for.

  Example:
    $ cap env

    CAP_ENV_PATH=/data/user/acrumley/3xtg-repurposing/bin/env
    CAP_CONTAINER_PATH=/data/user/acrumley/3xtg-repurposing/bin/container
    CAP_DATA_PATH=/data/user/acrumley/3xtg-repurposing/data
    CAP_ENVIRONMENT=default
    CAP_LOGS_PATH=/data/user/acrumley/3xtg-repurposing/logs
    CAP_PROJECT_NAME=3xtg-repurposing
    CAP_PROJECT_PATH=/data/user/acrumley/3xtg-repurposing
    CAP_RANDOM_SEED=16600
    CAP_RESULTS_PATH=/data/user/acrumley/3xtg-repurposing/results

EOF
}

cap_env() {
  cap_root_required "env"
  cap_env_parse_commandline_parameters "$@"

  # Snapshot the incoming environment variables. The cap_env_before
  # variable is created before the first snapshot so it will be in
  # the before and after snapshots. Otherwise, it shows up in the
  # cap_env_diff below.
  local cap_env_before=""
  cap_env_before="$(cap_env_snapshot)"

  # Load the CAPTURE environment.
  if [ -n "$environment_override" ]; then
    CAP_ENVIRONMENT="$environment_override"
  fi
  source "$CAP_INSTALL_PATH/lib/environment.sh"
  if [ -n "$environment_override" ]; then
    CAP_ENVIRONMENT="$environment_override"
  fi

  # Snapshot after the CAPTURE environment as loaded.
  cap_env_after="$(cap_env_snapshot)"

  # Determine list of variables created during environment loading.
  cap_env_diff="$(
    comm -13 \
      <(printf '%s\n' "$cap_env_before") \
      <(printf '%s\n' "$cap_env_after")
  )"

  # Display CAPTURE environment variables.
  echo
  for v in $cap_env_diff; do
    printf '%s=%q\n' "$v" "${!v}"
  done
  echo
}

cap_env_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o e: --long environment: -- "$@"); then
    echo "Use the 'cap help env' command for detailed help."
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  environment_override=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -e|--environment)
        environment_override=$2
        shift 2 ;;
      --)
        shift
        break;;
    esac
  done
}

# Snapshot current environment variables.
cap_env_snapshot() {
  compgen -v | sort
}
