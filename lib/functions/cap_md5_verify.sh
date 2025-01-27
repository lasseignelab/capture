#!/bin/bash

cap_md5_verify() {
  cap_md5_verify_parse_commandline_parameters "$@"

  local finalized_file
  finalized_file="$CAP_VERIFICATIONS_PATH/$CAP_VERIFY_NAME"_"$verify_name.md5"

  # If --finalize
  if [ "$CAP_VERIFY_CONTEXT" == "finalize" ]; then
    # If finalized output exists
    if [ -e "$finalized_file" ]; then
      # Ask the user if they want to overwrite the current output
      local response
      read -p "Overwrite existing finalized file (y/N)" response
      if [ "$response" == "y" ]; then
        rm "$finalized_file"
      else
        return 0
      fi
    fi
    # Finalize the verification output
    cap md5 \
      ${cap_md5_args[@]} \
      --normalize \
      --output "$finalized_file" \
      $verify_path

  elif [ "$CAP_VERIFY_CONTEXT" == "verify" ]; then
    #   If finalized output exists
    if [ -e "$finalized_file" ]; then
      mkdir "$CAP_REVIEW_PATH/verifications"
      local review_file
      review_file="$CAP_REVIEW_PATH/verifications/$CAP_VERIFY_NAME"_"$verify_name.md5"

      # Create the review verification output
      cap md5 \
        ${cap_md5_args[@]} \
        --normalize \
        --output "$review_file" \
        $verify_path

      # Compare the finalized and review files.
      local review_diff_file
      review_diff_file="$CAP_REVIEW_PATH/verifications/$CAP_VERIFY_NAME"_"$verify_name.diff"
      if cmp -s "$finalized_file" "$review_file"; then
        diff -s "$finalized_file" "$review_file" > "$review_diff_file"
      else
        diff -y "$finalized_file" "$review_file" > "$review_diff_file" || true
      fi
    else
      echo "Data file verification has not been finalized."
    fi
  fi
}

cap_md5_verify_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o "" --long ignore:,select: -- "$@"); then
    echo "See CAPTURE help for cap_md5_verify." >&2
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
    echo "Usage: cap_md5_verify [options] URL" >&2
    echo "See CAPTURE help for cap_md5_verify" >&2
    exit 1
  fi
  verify_path="$1"
  verify_name="${1##*/}"
}
