source "lib/functions/cap_array_value.sh"

@test "cap_array_value: Get the first array value with parameter" {
  temp_file="$BATS_TMPDIR/test.array"
  cat <<EOF > $temp_file
first
second
third
EOF
  run cap_array_value $temp_file 0

  [ "$status" -eq 0 ]
  [ "$output" = "first" ]
}

@test "cap_array_value: Get the second array value with parameter" {
  temp_file="$BATS_TMPDIR/test.array"
  cat <<EOF > $temp_file
first
second
third
EOF
  run cap_array_value $temp_file 1

  [ "$status" -eq 0 ]
  [ "$output" = "second" ]
}

@test "cap_array_value: Get the first array value with Slurm" {
  temp_file="$BATS_TMPDIR/test.array"
  cat <<EOF > $temp_file
first
second
third
EOF

  export SLURM_ARRAY_TASK_ID=0
  run cap_array_value $temp_file

  [ "$status" -eq 0 ]
  [ "$output" = "first" ]
}

@test "cap_array_value: Get the second array value with Slurm" {
  temp_file="$BATS_TMPDIR/test.array"
  cat <<EOF > $temp_file
first
second
third
EOF

  export SLURM_ARRAY_TASK_ID=1
  run cap_array_value $temp_file

  [ "$status" -eq 0 ]
  [ "$output" = "second" ]
}
