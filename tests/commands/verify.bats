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

@test "cap verify --dry-run: The output file is not blanked" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_dry_run.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  run cap verify --dry-run verifications/test_dry_run.sh

  [ "$status" -eq 0 ]
  [ "$output" == "Success: true" ]
  [[ ! -e "$PROJECTS_PATH/test/verifications/test_dry_run.out" ]]
}

@test "cap verify --slurm batch: Runs verification as a slurm batch" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_cap_verify_md5.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  temp_script=$(mktemp -p "$BATS_TMPDIR")
  stub mktemp " : echo '$temp_script'"
  stub sbatch "$temp_script : echo 'sbatch called correctly'"
  run cap verify --slurm "batch" verifications/test_cap_verify_md5.sh
  unstub mktemp
  unstub sbatch

  diff <(cat <<EOF
#!/bin/bash

#################################### SLURM ####################################
#SBATCH --job-name cap-verify
#SBATCH --output verifications/test_cap_verify_md5.out
#SBATCH --error verifications/test_cap_verify_md5.out
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=short

# Setup the runtime environment for the job.
source "/work/lib/environment.sh"
CAP_FUNCTION_GROUP=verify source /work/lib/functions.sh
. "$PROJECTS_PATH/test/verifications/test_cap_verify_md5.sh"
EOF
) "$temp_script"

  [ "$output" == "sbatch called correctly" ]
}

@test "cap verify --slurm run: Runs verification as a slurm run" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_cap_verify_md5.sh" "$PROJECTS_PATH/test/verifications"
  cd "$PROJECTS_PATH/test"

  temp_script=$(mktemp -p "$BATS_TMPDIR")
  stub mktemp " : echo '$temp_script'"
  stubbed_parameters=( \
    --job-name=cap-verify \
    --ntasks=1 \
    --cpus-per-task=1 \
    --mem=32G \
    --output=verifications/test_cap_verify_md5.out \
    --input=$temp_script \
    --export=ALL \
    bash
  )
  stub srun "${stubbed_parameters[*]} : echo 'srun called correctly'"
  run cap verify --slurm "run" verifications/test_cap_verify_md5.sh
  unstub mktemp
  unstub srun

  diff <(cat <<EOF
# Setup the runtime environment for the job.
source "/work/lib/environment.sh"
CAP_FUNCTION_GROUP=verify source /work/lib/functions.sh
. "$PROJECTS_PATH/test/verifications/test_cap_verify_md5.sh"
EOF
) "$temp_script"

  [ "$output" == "srun called correctly" ]
}

@test "cap verify: Perform md5 verification" {
  mkdir -p "$PROJECTS_PATH/test/verifications"
  cp "$FIXTURE_PATH/verifications/test_cap_verify_md5.sh" "$PROJECTS_PATH/test/verifications"
  cp -r "$MD5_FIXTURE_PATH/files" "$PROJECTS_PATH/test/data"
  cd "$PROJECTS_PATH/test"

  run cap verify verifications/test_cap_verify_md5.sh
  diff "$PROJECTS_PATH/test/verifications/test_cap_verify_md5.out" "$FIXTURE_PATH/outputs/all_files_only.out"

  echo "$output"
  [ "$status" -eq 0 ]
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

