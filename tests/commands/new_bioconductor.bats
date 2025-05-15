#!/usr/bin/env bats
load ../../node_modules/bats-mock/stub

@test "cap new: Dockerfile-template Bioconductor version" {
    # Make curl return a test Docker tags JSON response for Bioconductor.
    stub curl " : echo '$(cat tests/fixtures/bioconductor_tags.json)'"

    # Create a test project
    (
        cd $BATS_TMPDIR
        cap new test
    )

    unstub curl

    # Check that the version was updated.
    run grep -o "RELEASE_3_20-CAPTURE" $BATS_TMPDIR/test/bin/container/Dockerfile-template

    # Clean up the test project.
    rm -rf $BATS_TMPDIR/test

    [ "$status" -eq 0 ]
    [ "$output" == "RELEASE_3_20-CAPTURE" ]
}
