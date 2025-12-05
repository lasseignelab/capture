#!/bin/bash

cap_verify_description() {
  cat <<EOF
  Verifies that pipeline output is reproducible.
EOF
}

cap_verify_help() {
  cap_verify_description
  echo

  cat <<EOF
  The verify command runs CAPTURE verifications which are shell scripts that
  determine whether outputs are reproducible.  The output of verification
  scripts will be written to the verifications folder with the same name as the
  script with a '.out' extension. These files should be committed to source
  control so that reviewers can compare their results.

  Environment variable:

  CAP_VERIFICATION_OUTPUT_FILE: File name to append custom verification output.
  Verification helper functions automatically append to this file.

  Usage:
    cap verify FILE...

    FILE... One file name.

    Options:

    -n,--dry-run
            Lists the files that will have verifications performed in order to
            verify the expected files are included.  This is helpful when
            the files are large and take a long time to process.
    --slurm=[batch|run]
            Runs the verify command as a Slurm job. If the value is run then
            srun is used and the output stays connected to the current
            terminal session.  If the value is batch then sbatch is used and
            the output is written to verfications/<verification-name>.out.

  Example:

  Perform verifications for a step in the pipeline which will produce an
  output file named "verifications/01_download.out".

  cap verify verifications/01_download.sh
EOF
}

cap_verify() {
  cap_verify_parse_commandline_parameters "$@"

  # Setup the runtime environment for the job.
  source "$CAP_INSTALL_PATH/lib/environment.sh"
  CAP_FUNCTION_GROUP=verify source "$CAP_INSTALL_PATH/lib/functions.sh"

  # Run the script with the provided options.
  CAP_VERIFICATION_DRY_RUN="$dry_run"
  export CAP_VERIFICATION_DRY_RUN
  CAP_VERIFICATION_SLURM="$slurm"
  export CAP_VERIFICATION_SLURM

  # Setup the output file name environment variable.
  CAP_VERIFICATION_NAME="${verification_files##*/}" # remove path
  CAP_VERIFICATION_NAME="${CAP_VERIFICATION_NAME%.*}" # remove extension
  export CAP_VERIFICATION_NAME

  CAP_VERIFICATION_OUTPUT_FILE="verifications/$CAP_VERIFICATION_NAME.out"
  export CAP_VERIFICATION_OUTPUT_FILE

  . "${verification_files/verifications/$CAP_VERIFICATIONS_PATH}"

  # Output to the logs folder like the cap run command.
}

cap_verify_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o ns: --long dry-run,slurm: -- "$@"); then
    echo "Use the 'cap help verify' command for detailed help."
    return 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  dry_run=""
  slurm=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        slurm_args+="$1 "
        shift 1 ;;
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
    echo "Use the 'cap help verify' command for detailed help."
    exit 1
  fi

  # Verification files to verify.
  verification_files=( "$@" )
}
