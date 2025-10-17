#!/bin/bash

cap_container() {
  cap_container_parse_commandline_parameters "$@"

  sif_file=$cap_container_reference

  # Check that the format of the provided reference is correct
  if [[ ! "$sif_file" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+:.+ ]]; then
    echo "Error: REFERENCE must be in the format <namespace>/<repository>:<tag>"
    exit 1
  fi

  # Check if tag is 'latest'
  if [[ "${sif_file##*:}" == "latest" ]]; then
    echo "Warning: Please provide a specific tag instead of 'latest' to ensure reproducibility."
  fi

  sif_file="${sif_file##*/}"
  sif_file="${sif_file/:/_}.sif"
  sif_lock_dir="$CAP_CONTAINER_PATH/$sif_file.lock"

  # Attempt to acquire the lock. mkdir is an atomic operation.
  # The first task to execute this on a node will succeed.
  if mkdir "$sif_lock_dir" 2>/dev/null; then
    echo "Lock acquired for $sif_file. Pulling image..."

    # Ensure the lock is removed if the script is interrupted
    trap 'rm -rf "$sif_lock_dir"; echo "Lock released on interrupt."; exit' INT TERM EXIT

    # Check if the file exists in CAP_CONTAINER_PATH
    if [[ -f "$CAP_CONTAINER_PATH/$sif_file" ]]; then
      echo "The $sif_file is already available"
    else
      (
      cd "${CAP_CONTAINER_PATH}" || {
        echo "Error: Unable to CD to $CAP_CONTAINER_PATH"
            exit 1
          }

          case "$cap_container_type" in
            docker)
              echo "Pulling Docker image: $cap_container_reference"
              docker pull "$cap_container_reference"
              ;;
            singularity)
              echo "Pulling Singularity image: $cap_container_reference"
              singularity pull docker://"$cap_container_reference"
              ;;
            *)
              echo "Error: Invalid cap_container_type '$cap_container_type'. Use 'docker' or 'singularity'."
              exit 1
              ;;
          esac
        )
    fi

    # Release the lock by removing the directory
    rm -rf "$sif_lock_dir"
    echo "Lock for $sif_file is released."
    trap - INT TERM EXIT # Clear the trap
  else
    # Wait until the lock directory is gone
    echo "Waiting for lock on container image $sif_file..."
    while [ -d "$sif_lock_dir" ]; do
        sleep 2
    done
    echo "Lock is released on container image $sif_file. Proceeding."
  fi
}

cap_container_parse_commandline_parameters() {
  # Set default values for the named parameters
  # shellcheck disable=SC2153
  cap_container_type="${CAP_CONTAINER_TYPE}"

  # Parse the optional named command-line options
  while getopts "c:" opt; do
    case "$opt" in
      c)
        cap_container_type="$OPTARG"
        ;;
      *)
        echo "Usage: cap_container [options] reference" >&2
        echo "See CAPTURE help for cap_container" >&2
        exit 1
        ;;
    esac
  done
  shift $((OPTIND - 1))

  # Check that the required reference parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters" >&2
    echo "Usage: cap_container [options] reference" >&2
    echo "See CAPTURE help for cap_container" >&2
    exit 1
  fi

  cap_container_reference=$1
}
