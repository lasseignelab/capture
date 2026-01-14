#!/bin/bash

cap_run_description() {
  cat <<EOF
  Runs a CAPTURE framework job.
EOF
}

cap_run_help() {
  cap_run_description
  echo

  cat <<EOF
  The "run" command runs a CAPTURE framework job within the context of a
  reproducible research project.  It will configure the environment based
  on configuration defined by the current user. By default, the job runs in
  the current terminal session.  This command must be executed from the project
  root directory.

  Usage:
    cap run [options] FILE

    FILE  File name of the job to run.

    Options:

    -e,--environment
            Specifies the environment to run jobs in.  Environments allow
            different setups for a pipeline.  For instance, a pipeline may
            use internal copies of data during development but download that
            data when the pipeline is ran in a different environment. A
            project can provide environment specific configuration by
            including a file named <environment>.rc in the
            config/environments directory, e.g. lasseignelab.rc. See
            CAPTURE runtime environment documentation.
    -n,--dry-run
            Displays the contents of the job to run along with the context
            it will run in.
    -s,--slurm=[batch|run]
            Runs the script as a Slurm job. If the value is run then
            srun is used and the output stays connected to the current
            terminal session.  If the value is batch then sbatch is used and
            the output is written to the log file in the logs directory.

  Example:
    $ cap run src/01_download.sh

    CAPTURE environment: default

    View job output with the following command:
    cat logs/01_down_20241118_090854_tcrumley*

    Submitted batch job 29818073
EOF
}

cap_run() {
  cap_root_required "run"
  cap_run_parse_commandline_parameters "$@"

  job_directory=$(dirname "$job_file")
  job_name=$(basename "${job_file%.*}")

  # In order to insert the framework functions into the job, the job
  # is broken up into 3 pieces and then put back together with the
  # framework functions right before the code.
  slurm_shebang=$(head -n 1 "$job_file" | grep -E "^#!" )
  slurm_header=$(grep "#SBATCH" "$job_file")
  slurm_code=$(grep -v -E "(^#\!)|(#SBATCH)" "$job_file")

  # Put job back together with the framework function included.
#   slurm_job_run=$(cat <<EOF
# $slurm_shebang
# $slurm_header
# source $CAP_INSTALL_PATH/lib/functions.sh
# cap_log "Current Dir:  $PWD/"
# cap_log "Job File:     $(basename ${job_file})"
# cap_log "-----------Beginning Job-----------"
# $slurm_code
# cap_log "-----------Job Complete------------"
# EOF
# )
  # 1. Initialize an empty variable
  cap_log_block=""

  # 2. Only populate it if slurm equals "batch"
  if [[ "$slurm" == "batch" ]]; then
    cap_log_block=$(cat <<EOF
cap_log "Current Dir:      $PWD/"
cap_log "Job File:         $(basename "${job_file}")"
cap_log "Current User:     \${SLURM_JOB_USER}"
cap_log "Job ID:           \${SLURM_JOB_ID}"
cap_log "Slurm Host:       \${SLURM_SUBMIT_HOST}"
cap_log "Allocated Nodes: \$SLURM_JOB_NODELIST"
cap_log "CPUs per Node:    \$SLURM_CPUS_ON_NODE"
cap_log "-----------Beginning Job-----------"
EOF
)
fi

  # 3. Inject the block into your main template
  slurm_job_batch=$(cat <<EOF
$slurm_shebang
$slurm_header
source $CAP_INSTALL_PATH/lib/functions.sh
$cap_log_block
$slurm_code
${cap_log_block:+cap_log "-----------Job Complete------------"}
${cap_log_block:+cap_log "Efficieny Report:"}
${cap_log_block:+sleep 30}
${cap_log_block:+seff \$SLURM_JOB_ID}
EOF
)
#   slurm_job_batch=$(cat <<EOF
# $slurm_shebang
# $slurm_header
# source $CAP_INSTALL_PATH/lib/functions.sh
# cap_log "Current Dir:     $PWD/"
# cap_log "Job File:        $(basename ${job_file})"
# cap_log "Current User:    \${SLURM_JOB_USER}"
# cap_log "Job ID:          \${SLURM_JOB_ID}"
# cap_log "Slurm Host:      \${SLURM_SUBMIT_HOST}"
# cap_log "Allocated Nodes: \$SLURM_JOB_NODELIST"
# cap_log "CPUs per Node:   \$SLURM_CPUS_ON_NODE"
# cap_log "-----------Beginning Job-----------"
# $slurm_code
# cap_log "-----------Job Complete------------"
# cap_log "Efficieny Report:"
# sleep 30
# seff \$SLURM_JOB_ID
# EOF
# )

  # Setup the runtime environment for the job.
  if [ -n "$environment_override" ]; then
    CAP_ENVIRONMENT="$environment_override"
  fi
  source "$CAP_INSTALL_PATH/lib/environment.sh"
  if [ -n "$environment_override" ]; then
    CAP_ENVIRONMENT="$environment_override"
  fi
  cap_check_environment "$CAP_ENVIRONMENT"

  # Specify the log file names with their full path. Log file names will
  # begin with <job name>-<date>-<time>-<username>. If the job is an array
  # job then the job array id and task id will be appended.
  current_user=$(whoami)
  log_full_path=$(realpath "$CAP_LOGS_PATH")
  log_file_name="${job_name%.*}_$(date "+%Y%m%d_%H%M%S")_$current_user"
  # Inform the user how to check job output. The path will be relative
  # unless CAP_LOGS_PATH is outside the project.
  if [[ "$dry_run" == "true" || "$slurm" == "batch" ]]; then
    cat <<EOF

CAPTURE environment: $CAP_ENVIRONMENT

View job output with the following command:
cat ${log_full_path#"$(pwd)"/}/$log_file_name*

EOF
  fi
  # Add array values to log file name if it's an array job.
  if grep -q -E "^#SBATCH +--array=" "$job_file"; then
    log_file_name="$log_file_name"_%A_%a
  else
    log_file_name="$log_file_name"_%j
  fi

  # If it is a dry run then just display the environment variables and job
  # code. Otherwise, submit the job.
  if [[ "$dry_run" == "true" ]]; then
    cap_run_dry_run
  else
    # Submit to slurm or run immediately
    temp_batch_script=$(mktemp)
    # temp_run_script=$(mktemp)
    echo "$slurm_job_batch" > "$temp_batch_script"
    # echo "$slurm_job_run" > "$temp_run_script"
    case "$slurm" in
      batch)
        sbatch -D "$job_directory" \
          --job-name="${job_name%.*}-$CAP_PROJECT_NAME" \
          --output="$log_full_path/$log_file_name.out" \
          --error="$log_full_path/$log_file_name.err" \
          "$temp_batch_script"
        echo
        ;;
      run)
        srun \
          --job-name="${job_name%.*}-$CAP_PROJECT_NAME" \
          --output="/dev/stdout" \
          --input="$temp_batch_script" \
          --export=ALL \
          bash
        ;;
      *)
        # shellcheck disable=SC1090
        source "$temp_batch_script"
        ;;
    esac
  fi
}

cap_run_dry_run() {
  echo
  # Display the framework environment variables.
  env | grep -E "^CAP" | sort
  echo
  echo "Job: $job_name"
  echo
  # Display job code with line numbers.
  cat -n <<EOF
$slurm_job_batch
EOF
  echo
}

cap_run_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o ne:s: --long dry-run,environment:,slurm: -- "$@"); then
    echo "Use the 'cap help run' command for detailed help."
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  dry_run=false
  environment_override=""
  slurm=""

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -n|--dry-run)
        dry_run=true
        shift 1 ;;
      -e|--environment)
        environment_override=$2
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
    echo "Error: invalid value for -s,--slurm option"
    echo "Use the 'cap help run' command for detailed help."
    exit 1
  fi

  # Dry runs do not run as Slurm jobs
  if [[ "$dry_run" == "true" ]]; then
    slurm=""
  fi

  # Check that the required job file parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters"
    echo "Usage: cap run [options] FILE"
    echo "Use the 'cap help run' command for detailed help."
    exit 1
  fi
  job_file="$1"
}
