#!/bin/bash

cap_verify_md5() {
  cap_verify_md5_parse_commandline_parameters "$@"

  cap_md5_args+=(--append --output-files-only)
  if [[ "$CAP_VERIFICATION_DRY_RUN" == "true" ]]; then
    cap_md5_args+=(--dry-run)
  else
    cap_md5_args+=(--output "$CAP_VERIFICATION_OUTPUT_FILE")
  fi
  if [[ -n "$CAP_VERIFICATION_SLURM" ]]; then
    cap_md5_args+=(--slurm "$CAP_VERIFICATION_SLURM")
  fi

  cap md5 \
    ${cap_md5_args[@]} \
    $verify_path
}

cap_verify_md5_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o "" --long ignore:,select: -- "$@"); then
    echo "See CAPTURE help for cap_verify_md5." >&2
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  cap_md5_args=()

  # Parse the optional named command line options
  while true; do
    case "$1" in
      --select|--ignore)
        cap_md5_args+=($1 "$2")
        shift 2 ;;
      --)
        shift
        break;;
    esac
  done

  # Check that the required file url parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters" >&2
    echo "Usage: cap_verify_md5 [options] URL" >&2
    echo "See CAPTURE help for cap_verify_md5" >&2
    exit 1
  fi
  verify_path="$1"
}
