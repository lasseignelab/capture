#!/usr/bin/env bats
load ../../../node_modules/bats-mock/stub
load ../../../node_modules/bats-support/load
load ../../../node_modules/bats-assert/load

source "lib/functions/verify/cap_verify_append.sh"

setup() {
  CAP_VERIFICATIONS_PATH=$(mktemp -d -p "$BATS_TEMPDIR")
}

teardown() {
  rm -rf "$CAP_VERIFICATIONS_PATH"
}

@test "cap_verify_append: Create a verification output file" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN=""
  export CAP_VERIFICATION_DRY_RUN

  run cap_verify_append "Test"
  diff "$CAP_VERIFICATION_OUTPUT_FILE" <(echo "Test")

  [ "$status" -eq 0 ]
}

@test "cap_verify_append: Append to an existing verification output file" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN=""
  export CAP_VERIFICATION_DRY_RUN

  echo "Test1" >> "$CAP_VERIFICATION_OUTPUT_FILE"
  run cap_verify_append "Test2"
  diff "$CAP_VERIFICATION_OUTPUT_FILE" <(cat <<EOF
Test1
Test2
EOF
)

  [ "$status" -eq 0 ]
}

@test "cap_verify_append: Dry run only displays the text" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN="true"
  export CAP_VERIFICATION_DRY_RUN

  run cap_verify_append "Test"

  # Make sure an output file is not created.
  assert [ ! -e "$CAP_VERIFICATION_OUTPUT_FILE" ]

  [ "$status" -eq 0 ]
  [ "$output" == "Test" ]
}
