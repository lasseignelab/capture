#!/bin/bash

cap_data_download() {
  cap_data_download_parse_commandline_parameters "$@"

  # Determine the output folder or file name.
  # There is an assumption that the name of a tar file matches
  # the name of the output. This assumption will probably need
  # to be removed but we will wait until we have a real example
  # before we try to change this.
  local file_name
  file_name=$(basename "$cap_data_download_url")
  local output_name
  output_name="${file_name//\.tar.*/}"
  output_name="${output_name//\.gz/}"

  # Download data if the final output does not exist.
  if [ -e "$CAP_DATA_PATH/$output_name" ] || [ -e "$CAP_DATA_PATH/$file_name" ]; then
    echo "$file_name has already been downloaded"
  else
    local download_file="$CAP_DATA_PATH/$file_name"

    # Download the file.
    if ! wget -nv --retry-connrefused -O "$download_file" "$cap_data_download_url"; then
      echo "Error: URL not found" >&2
      exit 1
    fi

    # Check the md5sum if it is provided.
    if [ -n "$cap_data_download_md5sum" ]; then
      if echo "$cap_data_download_md5sum  $download_file" | md5sum -c -; then
        echo "File download checksum verified!"
      else
        echo >&2
        echo "File $file_name checksum verification failed!" >&2
        echo "The file was left in place for debugging purposes.  It will" >&2
        echo "need to be deleted before attempting another download." >&2
        echo >&2
        exit 1
      fi
    fi

    if [[ "$cap_data_download_unzip" == "true" ]]; then
      case "$file_name" in
        # Untar and remove downloads that are tar archives.
        *.tar|*.tar.gz)
          if tar -xf "$download_file" -C "$CAP_DATA_PATH"; then
            rm "$download_file"
          fi
          ;;
        # Unzip and remove downloads that are compressed files.
        *.gz)
          (
            cd "$CAP_DATA_PATH" || exit
            gunzip "$file_name"
          )
          ;;
      esac
    fi
  fi
}

cap_data_download_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o "" --long md5sum:,unzip -- "$@"); then
    echo "See CAPTURE help for cap_data_download." >&2
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  cap_data_download_md5sum=""
  cap_data_download_unzip=false

  # Parse the optional named command line options
  while true; do
    case "$1" in
      --md5sum)
        cap_data_download_md5sum="$2"
        shift 2 ;;
      --unzip)
        cap_data_download_unzip=true
        shift 1 ;;
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
