#!/bin/bash

cap_verify_append() {
  if [[ "$CAP_VERIFICATION_DRY_RUN" == "true" ]]; then
    echo "$1"
  else
    echo "$1" >> "${CAP_VERIFICATION_OUTPUT_FILE:-/dev/stdout}"
  fi
}
