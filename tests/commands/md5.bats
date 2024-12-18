#!/usr/bin/env bats
FIXTURE_PATH="tests/fixtures/md5"

@test "cap md5: All files in a folder" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/all.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: A specific file" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 -o $temp_output $FIXTURE_PATH/files/one.bin
    run diff $temp_output $FIXTURE_PATH/outputs/one.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --name parameter" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --name "three*" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/name.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --path parameter" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --path "*/outs/*" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/path.out

    echo "$output"
    [ "$status" -eq 0 ]
}
