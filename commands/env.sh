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
  paths.

  Usage:
    cap env

  Example:
    $ cap env

    CAP_CONDA_PATH=/data/user/acrumley/3xtg-repurposing/bin/conda
    CAP_CONTAINER_PATH=/data/user/acrumley/3xtg-repurposing/bin/docker
    CAP_DATA_PATH=/data/user/acrumley/3xtg-repurposing/data
    CAP_ENV=default
    CAP_LOGS_PATH=/data/user/acrumley/3xtg-repurposing/logs
    CAP_PROJECT_NAME=3xtg-repurposing
    CAP_PROJECT_PATH=/data/user/acrumley/3xtg-repurposing
    CAP_RANDOM_SEED=16600
    CAP_RESULTS_PATH=/data/user/acrumley/3xtg-repurposing/results

EOF
}

cap_env() {
  # Load the CAPTURE environment.
  source "$CAP_INSTALL_PATH/lib/environment.sh"

  # Display CAPTURE environment variables.
  echo
  env | grep -E "^CAP" | sort
  echo
}
