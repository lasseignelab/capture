#!/usr/bin/env bats

setup() {
  PROJECTS_PATH=$(mktemp -d -p "$BATS_TMPDIR")
  PROJECTS_PATH=$(realpath "$PROJECTS_PATH")
  (
  cd $PROJECTS_PATH
  cap new test
  )
}

@test "cap env: Command must be executed from the project root directory" {
  cd "$PROJECTS_PATH/test/data"

  run cap env

  [ "$status" -eq 2 ]
  [ "$output" == "The env command must be executed from the project root directory." ]
}

