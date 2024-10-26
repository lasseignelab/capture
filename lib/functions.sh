#!/bin/bash

cap_data_download() {
  cap_data_download_parse_commandline_parameters "$@"

  # Determine the output folder or file name.
  # There is an assumption that the name of a tar file matches
  # the name of the output. This assumption will probably need
  # to be removed but we will wait until we have a real example
  # before we try to change this.
  local file_name=$(basename "$cap_data_download_url")
  local output_name=$(echo "$file_name" | sed 's|\.tar.*||')

  # Download data if the final output does not exist.
  if [ -e "$CAP_DATA_PATH/$output_name" ]; then
    echo "$file_name has already been downloaded"
  else
    local download_file="$CAP_DATA_PATH/$file_name"

    # Download the file.
    wget -nv -O "$download_file" "$cap_data_download_url"

    # Check the md5sum if it is provided.
    if [ -n "$cap_data_download_md5sum" ]; then
      if echo "$cap_data_download_md5sum  $download_file" | md5sum -c -; then
        echo "File download checksum verified!"
      else
        echo "File download checksum verification failed!" >&2
        exit 1
      fi
    fi

    # Untar and remove downloads that are tar archives.
    if file "$download_file" | grep -q -E '(tar archive)|(gzip compressed data)'; then
      if tar -xf "$download_file" -C "$CAP_DATA_PATH"; then
        rm "$download_file"
      fi
    fi
  fi
}

cap_data_download_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o "" --long md5sum: -- "$@"); then
    echo "See CAPTURE help for cap_data_download." >&2
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  cap_data_download_md5sum=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      --md5sum)
        cap_data_download_md5sum="$2"
        shift 2 ;;
      --)
        shift
        break;;
    esac
  done

  # Check that the required file url parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters" >&2
    echo "Usage: cap_data_download [options] URL" >&2
    echo "See CAPTURE help for cap_data_download" >&2
    exit 1
  fi
  cap_data_download_url=$1
}
