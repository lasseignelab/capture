#!/bin/bash

cap_log() {
  echo "CAPTURE [BASH] [$(date +'%Y-%m-%d %H:%M')]${1:+ - "$@"}"
}
