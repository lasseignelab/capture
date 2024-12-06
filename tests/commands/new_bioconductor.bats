#!/usr/bin/env bats
load ../../node_modules/bats-mock/stub

@test "cap new: Dockerfile Bioconductor version" {
    # Make curl return a test JSON response.
    stub curl " : echo '$(cat tests/fixtures/bioconductor_tags.json)'"

    # Create a new project
    cd $BATS_TMPDIR
    cap new test

    # Check that the version was updated.
    run grep -o "RELEASE_3_20-CAPTURE" "test/bin/docker/Dockerfile"

    # Clean up the test project.
    rm -rf $BATS_TMPDIR/test

    [ "$status" -eq 0 ]
    [ "$output" == "RELEASE_3_20-CAPTURE" ]
}
