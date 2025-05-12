#!/usr/bin/env bats
load ../../../node_modules/bats-mock/stub

source "lib/functions/cap_container.sh"

setup() {
  CAP_CONTAINER_PATH=$(mktemp -d -p "${BATS_TMPDIR}")
  CONTAINER_FIXTURE_PATH=$(realpath "tests/fixtures/lib/functions/cap_container")
}

teardown() {
  rm -rf "${CAP_CONTAINER_PATH}"
}

@test "cap_container: setting -c to singularity" {
  CAP_CONTAINER_TYPE="singularity"

  stub singularity "pull docker://base/image:tag : cp ${CONTAINER_FIXTURE_PATH}/image_tag.sif ${CAP_CONTAINER_PATH}/image_tag.sif"

  run cap_container -c "singularity" "base/image:tag"

  unstub singularity

  diff "${CONTAINER_FIXTURE_PATH}/image_tag.sif" "${CAP_CONTAINER_PATH}/image_tag.sif"

  [ "$status" -eq "0" ]
  [ "$output" == "Pulling Singularity image: base/image:tag" ]
}

@test "cap_container: Check for sif file" {
  CAP_CONTAINER_TYPE="singularity"

  cp "${CONTAINER_FIXTURE_PATH}/image_tag.sif" "${CAP_CONTAINER_PATH}/image_tag.sif"

  run cap_container -c "singularity" "base/image:tag"

  [ "$status" -eq "0" ]
  [ "$output" == "The image_tag.sif is already available" ]
}

@test "cap_container: Check for tag" {
  CAP_CONTAINER_TYPE="singularity"

  run cap_container -c "singularity" "base/image"

  [ "$status" -eq "1" ]
  [ "$output" == "Error: REFERENCE must be in the format <namespace>/<repository>:<tag>" ]
}

@test "cap_container: Check for latest tag" {
  CAP_CONTAINER_TYPE="singularity"

  stub singularity "pull docker://base/image:latest : cp ${CONTAINER_FIXTURE_PATH}/image_latest.sif ${CAP_CONTAINER_PATH}/image_latest.sif"

  run cap_container -c "singularity" "base/image:latest"

  unstub singularity

  diff "${CONTAINER_FIXTURE_PATH}/image_latest.sif" "${CAP_CONTAINER_PATH}/image_latest.sif"

  EXPECTED_OUTPUT=$(cat <<EOF
Warning: Please provide a specific tag instead of 'latest' to ensure reproducibility.
Pulling Singularity image: base/image:latest
EOF
)

  [ "$status" -eq "0" ]
  [ "$output" == "$EXPECTED_OUTPUT" ]
}
