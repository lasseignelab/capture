#!/bin/bash

cap_check_environment() {
  if [[ ! -f "config/environments/$1.sh" ]]; then
    echo "The $1.sh environment file does not exist in config/environments."
    exit 2
  fi
}
