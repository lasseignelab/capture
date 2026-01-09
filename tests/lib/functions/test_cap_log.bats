#!/usr/bin/env bats

source "lib/functions/cap_log.sh"

@test "cap_log outputs the correct format and message" {
  date() { echo "2026-01-09 15:00"; }
  export -f date

  run cap_log "System Check"

  [ "$status" -eq 0 ]
  [ "$output" == "CAPTURE 2026-01-09 15:00 System Check" ]

  unset -f date
}

@test "cap_log outputs the correct format and message without quotes" {
  date() { echo "2026-01-09 15:00"; }
  export -f date

  run cap_log System Check

  [ "$status" -eq 0 ]
  [ "$output" == "CAPTURE 2026-01-09 15:00 System Check" ]

  unset -f date
}

@test "cap_log outputs with variables" {
  date() { echo "2026-01-09 15:00"; }
  var="Variable test"
  export -f date

  run cap_log $var

  [ "$status" -eq 0 ]
  [ "$output" == "CAPTURE 2026-01-09 15:00 Variable test" ]

  unset -f date
}

@test "cap_log handles empty input gracefully" {
  date() { echo "2026-01-09 15:00"; }
  export -f date

  run cap_log

  [ "$status" -eq 0 ]
  [ "$output" == "CAPTURE 2026-01-09 15:00" ]

  unset -f date
}
