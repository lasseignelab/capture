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

@test "cap_container: setting --container-type to singularity" {
CAP_CONTAINER_TYPE="singularity"

stub singularity "pull docker://base/image:tag : cp ${CONTAINER_FIXTURE_PATH}/image_tag.sif ${CAP_CONTAINER_PATH}/image_tag.sif"

run cap_container --container-type "singularity" "base/image:tag"

unstub singularity

diff "${CONTAINER_FIXTURE_PATH}/image_tag.sif" "${CAP_CONTAINER_PATH}/image_tag.sif"

  [ "$status" -eq "0" ]
  [ "$output" == "Pulling Singularity image: base/image:tag" ]
}

@test "cap_container: Check for sif file" {
  CAP_CONTAINER_TYPE="singularity"

  cp "${CONTAINER_FIXTURE_PATH}/image_tag.sif" "${CAP_CONTAINER_PATH}/image_tag.sif"

  run cap_container --container-type "singularity" "base/image:tag"

  [ "$status" -eq "1" ]
  [ "$output" == "The image_tag.sif is already available" ]
}
