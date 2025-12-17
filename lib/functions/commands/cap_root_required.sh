cap_root_required() {
  if [[ ! -f "config/pipeline.sh" ]]; then
    echo "The $1 command must be executed from the project root directory." >&2
    exit 2
  fi
}
