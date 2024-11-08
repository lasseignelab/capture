#!/bin/bash

cap_array_value() {
  # Check that the required file name parameter was provided
  if [ "$#" -lt 1 ]; then
    echo "Error: incorrect number of parameters" >&2
    echo "Usage: cap_array_value FILE [INDEX]" >&2
    echo "See CAPTURE documentation for detailed help." >&2
    exit 1
  fi
  local array_file
  array_file=$1

  # if an optional array index was not provided then default to the slurm
  # task id.
  local array_index
  if [ -z "$2" ]; then
    array_index="$SLURM_ARRAY_TASK_ID"
  else
    array_index="$2"
  fi

  local array_list
  if [ -f "$array_file" ]; then
    # If the input is a file then process the file.
    mapfile -t array_list < "$array_file"
  fi

  echo "${array_list[$array_index]}"
}
