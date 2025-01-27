#!/usr/bin/env bats

source "lib/functions/cap_md5_verify.sh"

setup() {
  MD5_FIXTURE_PATH="tests/fixtures/md5"
  VERIFY_FIXTURE_PATH="tests/fixtures/verify"

  CAP_DATA_PATH=$MD5_FIXTURE_PATH
  CAP_VERIFICATIONS_PATH=$(mktemp -d -p "$BATS_TEMPDIR")
  CAP_REVIEW_PATH=$(mktemp -d -p "$BATS_TEMPDIR")
}

teardown() {
  rm -rf "$CAP_VERIFICATIONS_PATH"
  rm -rf "$CAP_REVIEW_PATH"
}

@test "cap_md5_verify finalize: Create a verification output file" {
  CAP_VERIFY_CONTEXT="finalize"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  run cap_md5_verify "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATIONS_PATH/test_files.md5" "$MD5_FIXTURE_PATH/outputs/all_normalized.out"

  [ "$status" -eq 0 ]
}

@test "cap_md5_verify finalize: Overwrite an existing verification output file" {
  CAP_VERIFY_CONTEXT="finalize"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  # Simulate a finalized file having been created.
  cp "$MD5_FIXTURE_PATH/outputs/one.out" "$CAP_VERIFICATIONS_PATH/test_files.md5"
  # Overwrite file by answering the prompt with yes.
  run cap_md5_verify "$CAP_DATA_PATH/files" <<< "y"
  # Verify that the previous file was overwritten.
  diff "$CAP_VERIFICATIONS_PATH/test_files.md5" "$MD5_FIXTURE_PATH/outputs/all_normalized.out"

  [ "$status" -eq 0 ]
}

@test "cap_md5_verify finalize: Abort on an existing verification output file" {
  CAP_VERIFY_CONTEXT="finalize"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  # Simulate a finalized file having been created.
  cp "$MD5_FIXTURE_PATH/outputs/one.out" "$CAP_VERIFICATIONS_PATH/test_files.md5"
  # Don't overwrite file by answer the prompt with no.
  run cap_md5_verify "$CAP_DATA_PATH/files" <<< "n"
  # Verify that the previous file was NOT overwritten.
  diff "$CAP_VERIFICATIONS_PATH/test_files.md5" "$MD5_FIXTURE_PATH/outputs/one.out"

  [ "$status" -eq 0 ]
}

@test "cap_md5_verify finalize --select: Create a verification output file" {
  CAP_VERIFY_CONTEXT="finalize"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  run cap_md5_verify --select "*one.bin" --select "*two.bin" "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATIONS_PATH/test_files.md5" "$MD5_FIXTURE_PATH/outputs/one_two_normalized.out"

  [ "$status" -eq 0 ]
}

@test "cap_md5_verify finalize --ignore: Create a verification output file" {
  CAP_VERIFY_CONTEXT="finalize"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  run cap_md5_verify --ignore "*three.bin" --ignore "*four.bin" "$CAP_DATA_PATH/files"
  diff "$CAP_VERIFICATIONS_PATH/test_files.md5" "$MD5_FIXTURE_PATH/outputs/one_two_normalized.out"

  [ "$status" -eq 0 ]
}

@test "cap_md5_verify verify: Verify unfinalized output files" {
  CAP_VERIFY_CONTEXT="verify"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  run cap_md5_verify "$CAP_DATA_PATH/files"

  [ "$status" -eq 0 ]
  [ "$output" == "Data file verification has not been finalized." ]
}

@test "cap_md5_verify verify: Verify finalized output files that match" {
  CAP_VERIFY_CONTEXT="verify"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  # Simulate a finalized file having been created.
  cp "$MD5_FIXTURE_PATH/outputs/all_normalized.out" "$CAP_VERIFICATIONS_PATH/test_files.md5"
  run cap_md5_verify "$CAP_DATA_PATH/files"
  # Check that the finalized md5 matches the verification file
  diff "$CAP_VERIFICATIONS_PATH/test_files.md5" "$CAP_REVIEW_PATH/verifications/test_files.md5"
  # Check that there is no difference between the finalized and verification files.
  diff "$CAP_REVIEW_PATH/verifications/test_files.diff" <(cat <<EOF
Files $CAP_VERIFICATIONS_PATH/test_files.md5 and $CAP_REVIEW_PATH/verifications/test_files.md5 are identical
EOF
)

  [ "$status" -eq 0 ]
}

@test "cap_md5_verify verify: Verify finalized output files that mismatch" {
  CAP_VERIFY_CONTEXT="verify"
  export CAP_VERIFY_CONTEXT
  CAP_VERIFY_NAME="test"
  export CAP_VERIFY_NAME

  # Simulate a finalized file having been created.
  cp "$MD5_FIXTURE_PATH/outputs/one_normalized.out" "$CAP_VERIFICATIONS_PATH/test_files.md5"
  run cap_md5_verify --select "*three.bin" "$CAP_DATA_PATH/files"
  # Check that there is a difference between the finalized and verification files.
  diff -w "$CAP_REVIEW_PATH/verifications/test_files.diff" "$VERIFY_FIXTURE_PATH/mismatched.diff"

  [ "$status" -eq 0 ]
}

