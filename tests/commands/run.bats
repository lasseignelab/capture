#!/usr/bin/env bats
load ../../node_modules/bats-mock/stub

FIXTURE_PATH=$(realpath "tests/fixtures/run")

setup() {
  PROJECTS_PATH=$(mktemp -d -p "$BATS_TMPDIR")
  PROJECTS_PATH=$(realpath "$PROJECTS_PATH")
  (
  cd $PROJECTS_PATH
  cap new test
  )
  RANDOM_SEED=$(sed -n 's/export CAP_RANDOM_SEED="\([^"]*\)"/\1/p' $PROJECTS_PATH/test/config/pipeline.sh)
}

teardown() {
  rm -rf "${PROJECTS_PATH}"
}

@test "cap run: Run script in terminal" {

  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"

  run cap run src/job.sh

  expected_output="$(cat <<EOF

CAPTURE environment: default

Hello world!
EOF
)"
  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run --slurm run: Run script with srun" {

  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"

  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub mktemp " : echo '$temp_script'"
  srun_parameters=(
    --job-name=job-test
    --output=/dev/stdout
    --input=$temp_script
    --export=ALL
    bash
  )
  stub srun "${srun_parameters[*]} : echo 'srun called correctly'"

  run cap run --slurm run src/job.sh

  unstub mktemp
  unstub srun

  expected_output="$(cat <<EOF

CAPTURE environment: default

srun called correctly
EOF
)"
  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run --slurm batch: Run script as a slurm batch" {

  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"

  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub mktemp " : echo '$temp_script'"
  sbatch_parameters=(
    -D src
    --job-name=job-test
    --output=$PROJECTS_PATH/test/logs/job_20250324_132703_$(whoami)_%j.out
    --error=$PROJECTS_PATH/test/logs/job_20250324_132703_$(whoami)_%j.err
    $temp_script
  )
  stub sbatch "${sbatch_parameters[*]} : echo 'Submitted batch job 31787364'"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"

  run cap run --slurm batch src/job.sh

  unstub mktemp
  unstub sbatch
  unstub date

  expected_output="$(cat <<EOF

CAPTURE environment: default

View job output with the following command:
cat logs/job_20250324_132703_$(whoami)*

Submitted batch job 31787364
EOF
)"
  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run --slurm batch: Run array job as a slurm batch" {

  cp "$FIXTURE_PATH/array_job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"

  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub mktemp " : echo '$temp_script'"
  sbatch_parameters=(
    -D src
    --job-name=array_job-test
    --output=$PROJECTS_PATH/test/logs/array_job_20250324_132703_$(whoami)_%A_%a.out
    --error=$PROJECTS_PATH/test/logs/array_job_20250324_132703_$(whoami)_%A_%a.err
    $temp_script
  )
  stub sbatch "${sbatch_parameters[*]} : echo 'Submitted batch job 31787364'"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"

  run cap run --slurm batch src/array_job.sh

  unstub mktemp
  unstub sbatch
  unstub date

  expected_output="$(cat <<EOF

CAPTURE environment: default

View job output with the following command:
cat logs/array_job_20250324_132703_$(whoami)*

Submitted batch job 31787364
EOF
)"
  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run: Command must be executed from the project root directory" {

  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test/src"
  run cap run job.sh

  [ "$status" -eq 2 ]
  [ "$output" == "The run command must be executed from the project root directory." ]
}

@test "cap run: Dry run with default environment" {
  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"
  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"
  run cap run -n src/job.sh
  unstub date

  expected_output=$(cat <<EOF

CAPTURE environment: default

View job output with the following command:
cat logs/job_20250324_132703_$(whoami)*


CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_DEVELOPMENT_PATH=$CAP_DEVELOPMENT_PATH
CAP_ENVIRONMENT=default
CAP_ENV_PATH=$PROJECTS_PATH/test/bin/env
CAP_ETC_RC_PATH=$CAP_ETC_RC_PATH
CAP_HOME_RC_PATH=$CAP_HOME_RC_PATH
CAP_INSTALL_PATH=$CAP_INSTALL_PATH
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results
CAP_VERIFICATIONS_PATH=$PROJECTS_PATH/test/verifications

Job: job

     1  #!/bin/bash
     2  #SBATCH --nodes=1
     3  #SBATCH --ntasks=1
     4  #SBATCH --mem-per-cpu=16G
     5  #SBATCH --cpus-per-task=1
     6  #SBATCH --time=24:00:00
     7  #SBATCH --partition=medium
     8  source $CAP_DEVELOPMENT_PATH/lib/functions.sh
     9
    10
    11  echo "Hello world!"
EOF
)
  output=$(echo "$output" | expand | sed 's/[[:space:]]\+$//')

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run: Dry run with environment option specified" {
  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cp "$PROJECTS_PATH/test/config/environments/default.sh" \
     "$PROJECTS_PATH/test/config/environments/test.sh"
  cd "$PROJECTS_PATH/test"
  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"
  run cap run -n -e test src/job.sh
  unstub date

  expected_output=$(cat <<EOF

CAPTURE environment: test

View job output with the following command:
cat logs/job_20250324_132703_$(whoami)*


CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_DEVELOPMENT_PATH=$CAP_DEVELOPMENT_PATH
CAP_ENVIRONMENT=test
CAP_ENV_PATH=$PROJECTS_PATH/test/bin/env
CAP_ETC_RC_PATH=$CAP_ETC_RC_PATH
CAP_HOME_RC_PATH=$CAP_HOME_RC_PATH
CAP_INSTALL_PATH=$CAP_INSTALL_PATH
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results
CAP_VERIFICATIONS_PATH=$PROJECTS_PATH/test/verifications

Job: job

     1  #!/bin/bash
     2  #SBATCH --nodes=1
     3  #SBATCH --ntasks=1
     4  #SBATCH --mem-per-cpu=16G
     5  #SBATCH --cpus-per-task=1
     6  #SBATCH --time=24:00:00
     7  #SBATCH --partition=medium
     8  source $CAP_DEVELOPMENT_PATH/lib/functions.sh
     9
    10
    11  echo "Hello world!"
EOF
)
  output=$(echo "$output" | expand | sed 's/[[:space:]]\+$//')

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run: Invalid environment option specified" {
  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"
  run cap run -e invalid src/job.sh

  [ "$status" -eq 2 ]
  [ "$output" == "The invalid.sh environment file does not exist in config/environments." ]
}
