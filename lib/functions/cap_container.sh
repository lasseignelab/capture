#!/bin/bash

cap_container() {
  cap_container_parse_commandline_parameters "$@"

  sif_file=$cap_container_reference
  sif_file="${sif_file##*/}"
  sif_file="${sif_file/:/_}.sif"

  # Check if the file exists in CAP_CONTAINER_PATH
if [[ -f "$CAP_CONTAINER_PATH/$sif_file" ]]; then
    echo "The $sif_file is already available"
    exit 1
else
  (
  cd "${CAP_CONTAINER_PATH}" || {
    "Error: Unable to CD to $CAP_CONTAINER_PATH"
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
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o "" --long container-type: -- "$@"); then
    echo "See CAPTURE help for cap_container." >&2
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  # shellcheck disable=SC2153
  cap_container_type="${CAP_CONTAINER_TYPE}"

  # Parse the optional named command line options
  while true; do
    case "$1" in
      --container-type)
        cap_container_type="$2"
        shift 2 ;;
      --)
        shift
        break;;
    esac
  done

  # Check that the required file url parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters" >&2
    echo "Usage: cap_container [options] reference" >&2
    echo "See CAPTURE help for cap_container" >&2
    exit 1
  fi
  cap_container_reference=$1
}

