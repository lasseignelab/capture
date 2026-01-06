#!/usr/bin/env bats
load ../../node_modules/bats-mock/stub
load ../../node_modules/bats-support/load
load ../../node_modules/bats-assert/load

setup() {
  PROJECTS_PATH=$(mktemp -d -p "$BATS_TMPDIR")
  PROJECTS_PATH=$(realpath "$PROJECTS_PATH")
  cd $PROJECTS_PATH
}

@test "cap new: New projects have a bin/env directory" {

  run cap new test
  assert [ -d "$PROJECTS_PATH/test/bin/env" ]

  [ "$status" -eq 0 ]
}

