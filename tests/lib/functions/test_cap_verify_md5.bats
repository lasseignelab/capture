#!/usr/bin/env bats
load ../../../node_modules/bats-mock/stub
load ../../../node_modules/bats-support/load
load ../../../node_modules/bats-assert/load

source "lib/functions/verify/cap_verify_md5.sh"

setup() {
  MD5_FIXTURE_PATH="tests/fixtures/md5"
  VERIFY_FIXTURE_PATH="tests/fixtures/verify"

  CAP_DATA_PATH=$MD5_FIXTURE_PATH
  CAP_VERIFICATIONS_PATH=$(mktemp -d -p "$BATS_TEMPDIR")
}

teardown() {
  rm -rf "$CAP_VERIFICATIONS_PATH"
}

@test "cap_verify_md5: Create a verification output file" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN="false"
  export CAP_VERIFICATION_DRY_RUN

  run cap_verify_md5 "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATION_OUTPUT_FILE" "$MD5_FIXTURE_PATH/outputs/all_files_only.out"

  echo "$output"
  [ "$status" -eq 0 ]
}

@test "cap_verify_md5: Append to an existing verification output file" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN="false"
  export CAP_VERIFICATION_DRY_RUN

  # Simulate a file having been previously created.
  cp "$MD5_FIXTURE_PATH/outputs/all_files_only.out" "$CAP_VERIFICATION_OUTPUT_FILE"
  # Verify that the previous file was appended.
  run cap_verify_md5 "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATION_OUTPUT_FILE" "$MD5_FIXTURE_PATH/outputs/all_files_appended.out"

  [ "$status" -eq 0 ]
}

@test "cap_verify_md5: Dry run only displays file names to be verified" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN="true"
  export CAP_VERIFICATION_DRY_RUN

  run cap_verify_md5 "$CAP_DATA_PATH/files"

  # Make sure an output file is not created.
  assert [ ! -e "$CAP_VERIFICATION_OUTPUT_FILE" ]

  # Make sure the file list is output to the screen.
  expected_output="$(cat <<EOF
tests/fixtures/md5/files/one.bin
tests/fixtures/md5/files/outs/four.bin
tests/fixtures/md5/files/outs/three.bin
tests/fixtures/md5/files/two.bin
EOF
)"
  diff -y <(echo "$expected_output") <(echo "$output")

  [ "$status" -eq 0 ]
}

@test "cap_verify_md5 --select: Create a verification output file" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN="false"
  export CAP_VERIFICATION_DRY_RUN

  run cap_verify_md5 --select "*one.bin" --select "*two.bin" "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATION_OUTPUT_FILE" "$MD5_FIXTURE_PATH/outputs/one_two_files_only.out"

  [ "$status" -eq 0 ]
}

@test "cap_verify_md5 --ignore: Create a verification output file" {
  CAP_VERIFICATION_OUTPUT_FILE="$CAP_VERIFICATIONS_PATH/verification.out"
  export CAP_VERIFICATION_OUTPUT_FILE
  CAP_VERIFICATION_NAME="verification"
  export CAP_VERIFICATION_NAME
  CAP_VERIFICATION_DRY_RUN="false"
  export CAP_VERIFICATION_DRY_RUN


  run cap_verify_md5 --ignore "*three.bin" --ignore "*four.bin" "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATION_OUTPUT_FILE" "$MD5_FIXTURE_PATH/outputs/one_two_files_only.out"

  [ "$status" -eq 0 ]
}
