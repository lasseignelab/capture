#!/usr/bin/env bats

setup() {
  FIXTURE_PATH="tests/fixtures/env"

  PROJECTS_PATH=$(mktemp -d -p "$BATS_TMPDIR")
  PROJECTS_PATH=$(realpath "$PROJECTS_PATH")
  (
  cd $PROJECTS_PATH
  cap new test
  )
  RANDOM_SEED=$(sed -n 's/export CAP_RANDOM_SEED="\([^"]*\)"/\1/p' $PROJECTS_PATH/test/config/pipeline.sh)
}

@test "cap env: Show environment variables" {
  cd "$PROJECTS_PATH/test"

  run cap env

  expected_output=$(cat <<EOF

CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_ENVIRONMENT=default
CAP_ENV_PATH=$PROJECTS_PATH/test/bin/env
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results
CAP_VERIFICATIONS_PATH=$PROJECTS_PATH/test/verifications

EOF
)

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap env -e: Show lasseignelab environment variables" {
  cd "$PROJECTS_PATH/test"
  touch "$PROJECTS_PATH/test/config/environments/lasseignelab.sh"

  run cap env -e lasseignelab

  expected_output=$(cat <<EOF

CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_ENVIRONMENT=lasseignelab
CAP_ENV_PATH=$PROJECTS_PATH/test/bin/env
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results
CAP_VERIFICATIONS_PATH=$PROJECTS_PATH/test/verifications

EOF
)

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap env --environment: Show lasseignelab environment variables" {
  cd "$PROJECTS_PATH/test"
  touch "$PROJECTS_PATH/test/config/environments/lasseignelab.sh"

  run cap env --environment lasseignelab

  expected_output=$(cat <<EOF

CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_ENVIRONMENT=lasseignelab
CAP_ENV_PATH=$PROJECTS_PATH/test/bin/env
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results
CAP_VERIFICATIONS_PATH=$PROJECTS_PATH/test/verifications

EOF
)

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap env -e: Check for missing environment configuration file" {
  cd "$PROJECTS_PATH/test"

  run cap env -e lasseignelab

  expected_output=$(cat <<EOF
The lasseignelab.sh environment file does not exist in config/environments.
EOF
)

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 2 ]
}

@test "cap env: Command must be executed from the project root directory" {
  cd "$PROJECTS_PATH/test/data"

  run cap env

  [ "$status" -eq 2 ]
  [ "$output" == "The env command must be executed from the project root directory." ]
}

@test "cap env: Include user defined environment variables" {
  cp "$FIXTURE_PATH/.caprc" "$PROJECTS_PATH/test"
  cd "$PROJECTS_PATH/test"

  run cap env

  expected_output=$(cat <<EOF

CAP_CONTAINER_PATH=$PROJECTS_PATH/test/bin/container
CAP_CONTAINER_TYPE=docker
CAP_DATA_PATH=$PROJECTS_PATH/test/data
CAP_ENVIRONMENT=default
CAP_ENV_PATH=$PROJECTS_PATH/test/bin/env
CAP_LOGS_PATH=$PROJECTS_PATH/test/logs
CAP_PROJECT_NAME=test
CAP_PROJECT_PATH=$PROJECTS_PATH/test
CAP_RANDOM_SEED=$RANDOM_SEED
CAP_RESULTS_PATH=$PROJECTS_PATH/test/results
CAP_VERIFICATIONS_PATH=$PROJECTS_PATH/test/verifications
TEST_VARIABLE=test

EOF
)

  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

