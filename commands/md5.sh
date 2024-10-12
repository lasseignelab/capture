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
  specified.  It will show a list of all files included to ensure that the
  result is as expected.

  Usage:
    cap md5 [options] FILE...

    FILE... can be one or more file and/or directory specifications.

    Options:

    -n,--dry-run
            Lists the files that will have md5sums calculated in order to
            verify the expected files are included.  This is helpful when
            the files are large and take a long time to process.

    -o,--output=FILE
            Specify an output file name to write the results to.

    --slurm=[batch|run]
            Runs the md5 command as a Slurm job. If the value is run then
            srun is used and the output stays connected to the current
            terminal session.  If the value is batch then sbatch is used and
            the output is written to cap-md5-<job_id>.out

  Example:
    $ cap md5 *

    Files included:
    43bd364a97a38fb1da7c57e6381886c1  capture/LICENSE
    b794df25f796ac80680c0e4d27308bce  capture/commands/md5.sh
    0d9281c3586c420130bcb5d25c8a151a  capture/lab
    5e79c988140af1b7bd5735b0bf96306b  capture/README.md
    783a44ffae97afbce3f1649c5ff517a5  capture/install.sh

    Combined MD5 checksum:
    a225199964b84bdeef33bafe3df7c10b
EOF
}

cap_md5() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o no:s: --long dry-run,output:,slurm: -- "$@"); then
    echo "Use the 'cap help md5' command for detailed help."
    return 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  dry_run=false
  output_file=""
  slurm=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        shift 1 ;;
      -o|--output)
        output_file="$2"
        shift 2 ;;
      -s|--slurm)
        slurm="$2"
        shift 2 ;;
      --)
        shift
        break;;
    esac
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

  # Submit to slurm or run immediately
  case "$slurm" in
    batch)
      current_path=$(pwd)
      if [[ "$output_file" == "" ]]; then
        output_file='cap-md5-%j.out'
      fi
      sbatch <<EOF
#!/bin/bash

#################################### SLURM ####################################
#SBATCH --job-name cap-md5
#SBATCH --output $output_file
#SBATCH --error $output_file
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=short

cap md5 ${@:1}
echo "Ran from: $current_path"
EOF
      ;;
    run)
      srun \
        --job-name=cap-md5 \
        --ntasks=1 \
        --cpus-per-task=1 \
        --mem=32G \
        --output="${output_file:-/dev/stdout}" \
        bash -c 'cap md5 "$@"' _ "${@}"
      ;;
    *)
      {
        if [[ "$dry_run" == "true" ]]; then
          find "${@:1}" -type f ! -path '*/\.*' | sort
        else
          # Compute checksums for all files
          echo -e '\nFiles included:'
          checksums=$(cap_md5_find "${@:1}")
          echo "$checksums"

          # Compute single checksum based on the checksums of all files
          echo -e '\nCombined MD5 checksum:'
          echo "$checksums" | cut -d ' ' -f1 | md5sum | cut -d ' ' -f1
          echo
        fi
      } > "${output_file:-/dev/stdout}"
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
  find "${@:1}" -type f ! -path '*/\.*' -exec md5sum {} + | sort -k2,2
}
