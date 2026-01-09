#!/bin/bash

cap_log() {
  echo "CAPTURE $(date +'%Y-%m-%d %H:%M')${1:+ "$@"}"
}
