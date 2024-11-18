source "lib/functions/cap_array_value.sh"

setup() {
  TEMP_FILE="$BATS_TMPDIR/test.array"
  export TEMP_FILE
  cat <<EOF > $TEMP_FILE
first
second
third
EOF
}

@test "cap_array_value: Get the first array value with parameter" {
  run cap_array_value $TEMP_FILE 0

  [ "$status" -eq 0 ]
  [ "$output" = "first" ]
}

@test "cap_array_value: Get the second array value with parameter" {
  run cap_array_value $TEMP_FILE 1

  [ "$status" -eq 0 ]
  [ "$output" = "second" ]
}

@test "cap_array_value: Get the first array value with Slurm" {
  export SLURM_ARRAY_TASK_ID=0
  run cap_array_value $TEMP_FILE

  [ "$status" -eq 0 ]
  [ "$output" = "first" ]
}

@test "cap_array_value: Get the second array value with Slurm" {
  export SLURM_ARRAY_TASK_ID=1
  run cap_array_value $TEMP_FILE

  [ "$status" -eq 0 ]
  [ "$output" = "second" ]
}
