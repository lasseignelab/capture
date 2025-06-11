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

@test "cap run: Run script without options" {

  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"
  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub mktemp " : echo '$temp_script'"
  sbatch_parameters=(
    -D src
    --job-name=job-test
    --output=$PROJECTS_PATH/test/logs/job_20250324_132703_$(whoami).out
    --error=$PROJECTS_PATH/test/logs/job_20250324_132703_$(whoami).err
    $temp_script
  )

  stub sbatch "${sbatch_parameters[*]} : echo 'Submitted batch job 31787364'"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"
  run cap run src/job.sh
  unstub mktemp
  unstub sbatch
  unstub date

  expected_output="$(cat <<EOF

View job output with the following command:
cat logs/job_20250324_132703_$(whoami)*

Submitted batch job 31787364
EOF
)"
  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap run: Dry run with default environment" {
  cp "$FIXTURE_PATH/job.sh" "$PROJECTS_PATH/test/src"
  cd "$PROJECTS_PATH/test"
  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"
  run cap run -n src/job.sh
  unstub date

  expected_output=$(cat <<EOF

View job output with the following command:
cat logs/job_20250324_132703_$(whoami)*


Environment: default

CAP_CONDA_PATH=$PROJECTS_PATH/test/bin/conda
CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_DEVELOPMENT_PATH=$CAP_DEVELOPMENT_PATH
CAP_ENV=default
CAP_ETC_RC_PATH=$CAP_ETC_RC_PATH
CAP_HOME_RC_PATH=$CAP_HOME_RC_PATH
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results

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
  cd "$PROJECTS_PATH/test"
  temp_script="$(mktemp -p "$BATS_TMPDIR")"
  stub date "+%Y%m%d_%H%M%S : echo '20250324_132703'"
  run cap run -n -e test src/job.sh
  unstub date

  expected_output=$(cat <<EOF

View job output with the following command:
cat logs/job_20250324_132703_$(whoami)*


Environment: test

CAP_CONDA_PATH=$PROJECTS_PATH/test/bin/conda
CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_DEVELOPMENT_PATH=$CAP_DEVELOPMENT_PATH
CAP_ENV=test
CAP_ETC_RC_PATH=$CAP_ETC_RC_PATH
CAP_HOME_RC_PATH=$CAP_HOME_RC_PATH
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results

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
