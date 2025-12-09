#!/usr/bin/env bats
load ../../node_modules/bats-mock/stub

setup() {
  FIXTURE_PATH=$(realpath "tests/fixtures/verify")
  MD5_FIXTURE_PATH=$(realpath "tests/fixtures/md5")

  PROJECTS_PATH=$(mktemp -d -p "$BATS_TMPDIR")
  PROJECTS_PATH=$(realpath "$PROJECTS_PATH")
  (
  cd $PROJECTS_PATH
  cap new test
  )
}

@test "cap verify: CAP_VERIFIFICATION_OUTPUT_FILE is set to the verification file name" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_output_file.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify verifications/test_output_file.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: verifications/test_output_file.out" ]
}

@test "cap verify: CAP_VERIFIFICATION_NAME is set to the verification name" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_name.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify verifications/test_name.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: test_name" ]
}

@test "cap verify: CAP_VERIFIFICATION_DRY_RUN is set to blank" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_dry_run.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify verifications/test_dry_run.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: " ]
}

@test "cap verify --dry-run: CAP_VERIFIFICATION_DRY_RUN is set to true" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_dry_run.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify --dry-run verifications/test_dry_run.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: true" ]
}

@test "cap verify -n: CAP_VERIFIFICATION_DRY_RUN is set to true" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_dry_run.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify -n verifications/test_dry_run.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: true" ]
}

@test "cap verify: CAP_VERIFIFICATION_SLURM is set to the slurm option" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_slurm.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify verifications/test_slurm.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: " ]
}

@test "cap verify --slurm batch: CAP_VERIFIFICATION_SLURM is set to the slurm option" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_slurm.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify --slurm "batch" verifications/test_slurm.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: batch" ]
}

@test "cap verify --slurm run: CAP_VERIFIFICATION_SLURM is set to the slurm option" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_slurm.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify --slurm "run" verifications/test_slurm.sh

  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" == "Success: run" ]
}

@test "cap verify: Erase output file before performing md5 verification" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_cap_verify_md5.sh" "$PROJECTS_PATH/test/verifications"
  cp -r "$MD5_FIXTURE_PATH/files" "$PROJECTS_PATH/test/data"
  cp "$FIXTURE_PATH/outputs/all_files_only.out" "$PROJECTS_PATH/test/verifications/test_cap_verify_md5.out"
  cd "$PROJECTS_PATH/test"

  run cap verify verifications/test_cap_verify_md5.sh
  diff "$PROJECTS_PATH/test/verifications/test_cap_verify_md5.out" "$FIXTURE_PATH/outputs/all_files_only.out"

  echo "$output"
  [ "$status" -eq 0 ]
}

