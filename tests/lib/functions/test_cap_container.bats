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

  EXPECTED_OUTPUT=$(cat <<EOF
Lock acquired for image_tag.sif. Pulling image...
Pulling Singularity image: base/image:tag
Lock for image_tag.sif is released.
EOF
)

  [ "$status" -eq "0" ]
  [ "$output" == "$EXPECTED_OUTPUT" ]
}

@test "cap_container: Check for sif file" {
  CAP_CONTAINER_TYPE="singularity"

  cp "${CONTAINER_FIXTURE_PATH}/image_tag.sif" "${CAP_CONTAINER_PATH}/image_tag.sif"

  run cap_container -c "singularity" "base/image:tag"

  EXPECTED_OUTPUT=$(cat <<EOF
The image_tag.sif is already available
EOF
)

  [ "$status" -eq "0" ]
  [ "$output" == "$EXPECTED_OUTPUT" ]
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
Lock acquired for image_latest.sif. Pulling image...
Pulling Singularity image: base/image:latest
Lock for image_latest.sif is released.
EOF
)

  [ "$status" -eq "0" ]
  [ "$output" == "$EXPECTED_OUTPUT" ]
}

@test "cap_container: Wait for lock to clear on array jobs" {
  mkdir "${CAP_CONTAINER_PATH}/image_tag.sif.lock"

  stub sleep "2 : rmdir ${CAP_CONTAINER_PATH}/image_tag.sif.lock"

  run cap_container -c "singularity" "base/image:tag"

  unstub sleep

  EXPECTED_OUTPUT=$(cat <<EOF
Waiting for lock on container image image_tag.sif...
Lock is released on container image image_tag.sif. Proceeding.
EOF
)

  [ "$status" -eq "0" ]
  [ "$output" == "$EXPECTED_OUTPUT" ]
}

