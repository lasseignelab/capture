#!/bin/bash

cap_md5_description() {
  cat <<EOF
  Calculates a combined MD5 checksum for one or more files.
EOF
}

cap_md5_help() {
  cap_md5_description
  echo

  cat <<EOF
  The "md5" command produces a combined MD5 checksum for all the files
  specified. It will show a list of all files included to ensure that the
  result is as expected. The purpose of this command is to determine whether
  files downloaded or created are complete and accurate.

  Usage:
    cap md5 [options] FILE...

    FILE... One or more file and/or directory names or patterns. For
            directories, all files in the directory and its subdirectories will
            be included.

    Options:

    --ignore=PATTERN
            Exclude files matching the file PATTERN based on the full relative
            path. If the option is specified multiple times, all files matching
            any of the patterns will be EXCLUDED (logical OR). The selector will
            generally have wildcards. Ensure patterns are quoted ("*pattern*")
            to prevent unintended shell expansion.

    -n,--dry-run
            Lists the files that will have md5sums calculated in order to
            verify the expected files are included.  This is helpful when
            the files are large and take a long time to process.

    --normalize
            Normalizes the output file paths so that files in different root
            directories can be easily compared.

    -o,--output=FILE
            Specify an output file name to write the results to.

    --select=PATTERN
            Include only files matching the file PATTERN based on the full
            relative path. If the option is specified multiple times, all files
            matching any of the patterns will be INCLUDED (logical OR). The
            selector will generally have wildcards. Ensure patterns are quoted
            ("*pattern*") to prevent unintended shell expansion.

    --slurm=[batch|run]
            Runs the md5 command as a Slurm job. If the value is run then
            srun is used and the output stays connected to the current
            terminal session.  If the value is batch then sbatch is used and
            the output is written to cap-md5-<job_id>.out

  Examples:
    $ cap md5 files/*

    Files included:
    b3ac2b8b9998bf504ef708ec837a4cce  files/one.bin
    8d62064673ecb2a440b8802a2f752e8a  files/outs/four.bin
    74a08ee2de381ec8e19da52ad36bb5ae  files/outs/three.bin
    009c79f013fe8d4d97c95bf5ceea68ed  files/two.bin

    Combined MD5 checksum:
    1060bcc0958e5cc774f84ccd24a3b010

    $ cap md5 --select "*/outs/*" files/*

    Files included:
    8d62064673ecb2a440b8802a2f752e8a  files/outs/four.bin
    74a08ee2de381ec8e19da52ad36bb5ae  files/outs/three.bin

    Combined MD5 checksum:
    feaaf18494b99f6570ab6e4730f9e4af

    $ cap md5 --ignore "*/outs/*" files/*

    Files included:
    b3ac2b8b9998bf504ef708ec837a4cce  files/one.bin
    009c79f013fe8d4d97c95bf5ceea68ed  files/two.bin

    Combined MD5 checksum:
    c6f882353ed4c63582276bdd49974a86
EOF
}

cap_md5() {
  cap_md5_parse_commandline_parameters "$@"

  # Submit to slurm or run immediately
  case "$slurm" in
    batch)
      # Create a temporary script and run it as a Slurm batch job.
      current_path=$(pwd)
      if [[ "$output_file" == "" ]]; then
        output_file='cap-md5-%j.out'
      fi

      # Prepare a temporary script for running the command in Slurm.
      # The temporary file was introduced to make the code testable by BATS.
      temp_batch_script=$(mktemp)
      cat <<EOF > "$temp_batch_script"
#!/bin/bash

#################################### SLURM ####################################
#SBATCH --job-name cap-md5
#SBATCH --output $output_file
#SBATCH --error $output_file
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=short

cap md5 $slurm_args ${md5_files[@]}
echo "Ran from: $current_path"
EOF
      sbatch "$temp_batch_script"

      ;;
    run)
      # Prepare a temporary script for running the command in Slurm.
      # The temporary file was introduced to make the code testable by BATS.
      temp_run_script=$(mktemp)
      cat <<EOF > "$temp_run_script"
cap md5 $slurm_args ${md5_files[@]}
EOF

      srun \
        --job-name=cap-md5 \
        --ntasks=1 \
        --cpus-per-task=1 \
        --mem=32G \
        --output="${output_file:-/dev/stdout}" \
        --input="$temp_run_script" \
        --export=ALL \
        bash
      ;;
    *)
      local temp_output_file
      temp_output_file=$(mktemp)
      {
        if [[ "$dry_run" == "true" ]]; then
          # shellcheck disable=SC2068
          find -H -L ${md5_files[@]} "${ignore_filter[@]}" \( "${select_filter[@]}" \) -type f ! -path '*/\.*' | sort
        else
          # Compute checksums for all files
          echo -e '\nFiles included:'
          checksums=$(cap_md5_find)
          echo "$checksums"

          # Compute single checksum based on the checksums of all files
          echo -e '\nCombined MD5 checksum:'
          echo "$checksums" | cut -d ' ' -f1 | md5sum | cut -d ' ' -f1
          echo
        fi
      } > "$temp_output_file"
      if [[ "$normalize" == "true" && "$dry_run" == "false" ]]; then
        cap_md5_normalize "$temp_output_file"
      fi
      cat "$temp_output_file" > "${output_file:-/dev/stdout}"
      ;;
  esac
}

###############################################################################
# Finds all matching files and produces an MD5 checksum for each file.
# Results are sorted by file path and name.
#
# Usage:
# > cap_md5_find FILE...
#
# Example:
# > cap_md5_file ~/bin/capture/commands
# 91845ed3e6ed80b6c93ffa4bc0587c42  bin/capture/commands/md5dir.sh
# d2760f02c9d55fb4bf78d9ed0b398c4d  bin/capture/commands/md5.sh
#
###############################################################################
cap_md5_find() {
  # shellcheck disable=SC2068
  find -H -L ${md5_files[@]} "${ignore_filter[@]}" \( "${select_filter[@]}" \) -type f ! -path '*/\.*' -exec md5sum {} + | sort -k2,2
}

cap_md5_normalize() {
  # Define the file containing the list of file paths
  local file_name
  file_name="$1"
  local temp_file
  temp_file=$(mktemp)
  grep -E "[a-f0-9]{32} +" "$file_name" | cut -f 3 -d " " > "$temp_file"

  # Read the first line as the initial common prefix
  read -r common_prefix < "$temp_file"
  common_prefix=$(dirname "$common_prefix")/

  # Iterate over each line in the file
  while read -r line; do
    # Find the longest common prefix between the current common_prefix and the current line
    line=$(dirname "$line")/
    while [[ "${line#"$common_prefix"}" == "$line" ]]; do
      # Shorten the common_prefix by removing the last character until it matches
      common_prefix="${common_prefix%?}"
    done
  done < "$temp_file"

  # Clean up the temp file.
  rm "$temp_file"

  # Make sure the common prefix ends with a directory
  common_prefix="${common_prefix%/*}/"

  # Normalize the input file by replacing the path prefixes.
  sed -i "s|$common_prefix||" "$file_name"

  # Record the normalized path that was removed.
  echo "Normalized path: ${common_prefix}" >> "${file_name}"
}

cap_md5_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o no:s: --long dry-run,ignore:,normalize,output:,select:,slurm: -- "$@"); then
    echo "Use the 'cap help md5' command for detailed help."
    return 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  dry_run=false
  normalize=false
  ignore_values=()
  select_values=()
  output_file=""
  slurm=""

  # Save the original args for use with Slurm.
  slurm_args=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        slurm_args+="$1 "
        shift 1 ;;
      --ignore)
        ignore_values+=("$2")
        slurm_args+="$1 \"$2\" "
        shift 2 ;;
      --normalize)
        normalize=true
        slurm_args+="$1 "
        shift 1 ;;
      -o|--output)
        output_file="$2"
        slurm_args+="$1 \"$2\" "
        shift 2 ;;
      --select)
        select_values+=("$2")
        slurm_args+="$1 \"$2\" "
        shift 2 ;;
      -s|--slurm)
        slurm="$2"
        shift 2 ;;
      --)
        shift
        break;;
    esac
  done

  # Transform the --ignore values into filter options
  ignore_filter=()
  for ignore_value in "${ignore_values[@]}"; do
    ignore_filter+=(! -path "$ignore_value")
  done

  # Transform the --select values into filter options
  if [ ${#select_values[@]} -eq 0 ]; then
    select_filter=(-path "*")
  else
    select_filter=()
  fi

  for select_value in "${select_values[@]}"; do
    if [ ${#select_filter[@]} -eq 0 ]; then
      select_filter=(-path "$select_value")
    else
      select_filter+=(-o -path "$select_value")
    fi
  done

  # Validate the slurm option value
  if [[ "$slurm" != "batch" && "$slurm" != "run" && "$slurm" != "" ]]; then
    echo "Error: invalid value for --slurm option"
    echo "Use the 'cap help md5' command for detailed help."
    exit 1
  fi

  # Dry runs do not run as Slurm jobs
  if [[ "$dry_run" == "true" ]]; then
    slurm=""
  fi

  # Files and/or directories to compute md5 sums on.
  md5_files=( "$@" )
}
