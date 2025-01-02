#!/usr/bin/env bats
load ../../node_modules/bats-mock/stub

FIXTURE_PATH="tests/fixtures/md5"

# Slurm option.
# Dry run option.

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

@test "cap md5: --select a file in subdirectories" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --select "*/three.bin" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/name.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --select a directory in subdirectories" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --select "*/outs/*" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/outs.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --select two files in subdirectories" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --select "*/three.bin" --select "*/four.bin" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/outs.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --ignore a file in subdirectories" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --ignore "*/three.bin" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/ignore_file.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --ignore a directory in subdirectories" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --ignore "*/outs/*" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/ignore_path.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5: --ignore two files in subdirectories" {
    temp_output=$(mktemp -p "$BATS_TEMPDIR")
    cap md5 --ignore "*/one.bin" --ignore "*/two.bin" -o $temp_output $FIXTURE_PATH/files
    run diff $temp_output $FIXTURE_PATH/outputs/outs.out

    echo "$output"
    [ "$status" -eq 0 ]
}

@test "cap md5 --slurm batch: All files in a folder" {

    temp_script=$(mktemp -p "$BATS_TEMPDIR")
    stub mktemp " : echo '$temp_script'"
    stub sbatch "$temp_script : echo 'sbatch called correctly'"
    run cap md5 --slurm batch -o "test/output.txt" $FIXTURE_PATH/files
    unstub mktemp
    unstub sbatch

    diff <(cat <<EOF
#!/bin/bash

#################################### SLURM ####################################
#SBATCH --job-name cap-md5
#SBATCH --output test/output.txt
#SBATCH --error test/output.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=short

cap md5 -o "test/output.txt"  $FIXTURE_PATH/files
echo "Ran from: $(pwd)"
EOF
) "$temp_script"

    [ "$output" == "sbatch called correctly" ]
}

@test "cap md5 --slurm batch: --select a directory in subdirectories" {

    temp_script=$(mktemp -p "$BATS_TEMPDIR")
    stub mktemp " : echo '$temp_script'"
    stub sbatch "$temp_script : echo 'sbatch called correctly'"
    run cap md5 --select "*/outs/*" --slurm batch -o "test/output.txt" $FIXTURE_PATH/files
    unstub mktemp
    unstub sbatch

    diff <(cat <<EOF
#!/bin/bash

#################################### SLURM ####################################
#SBATCH --job-name cap-md5
#SBATCH --output test/output.txt
#SBATCH --error test/output.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=short

cap md5 --select "*/outs/*" -o "test/output.txt"  $FIXTURE_PATH/files
echo "Ran from: $(pwd)"
EOF
) "$temp_script"

    [ "$output" == "sbatch called correctly" ]
}

@test "cap md5 --slurm batch: --ignore a directory in subdirectories" {

    temp_script=$(mktemp -p "$BATS_TEMPDIR")
    stub mktemp " : echo '$temp_script'"
    stub sbatch "$temp_script : echo 'sbatch called correctly'"
    run cap md5 --ignore "*/outs/*" --slurm batch -o "test/output.txt" $FIXTURE_PATH/files
    unstub mktemp
    unstub sbatch

    diff <(cat <<EOF
#!/bin/bash

#################################### SLURM ####################################
#SBATCH --job-name cap-md5
#SBATCH --output test/output.txt
#SBATCH --error test/output.txt
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=32G
#SBATCH --partition=short

cap md5 --ignore "*/outs/*" -o "test/output.txt"  $FIXTURE_PATH/files
echo "Ran from: $(pwd)"
EOF
) "$temp_script"

    [ "$output" == "sbatch called correctly" ]
}

@test "cap md5 --slurm run: All files in a folder" {
    temp_script=$(mktemp -p "$BATS_TEMPDIR")
    stub mktemp " : echo '$temp_script'"
    stub srun "--job-name=cap-md5 --ntasks=1 --cpus-per-task=1 --mem=32G --output=/dev/stdout $temp_script : echo 'srun called correctly'"
    run cap md5 --slurm "run" $FIXTURE_PATH/files
    unstub mktemp
    unstub srun

    diff <(cat <<EOF
#!/bin/bash
cap md5 $FIXTURE_PATH/files
EOF
) "$temp_script"

    [ "$output" == "srun called correctly" ]
}

