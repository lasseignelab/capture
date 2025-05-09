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
