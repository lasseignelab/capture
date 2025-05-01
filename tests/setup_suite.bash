setup_suite() {
  # Make sure the `cap` command in this CAPTURE code base is used in tests
  # instead of the one installed in the system.
  PATH="$(pwd):$PATH"
  export PATH

  # Location of the CAPTURE framework development environment.
  CAP_DEVELOPMENT_PATH="$(pwd)"
  export CAP_DEVELOPMENT_PATH

  CAP_ETC_RC_PATH="$(mktemp -p "$BATS_TEMPDIR")"
  export CAP_ETC_RC_PATH
  CAP_HOME_RC_PATH="$(mktemp -p "$BATS_TEMPDIR")"
  export CAP_HOME_RC_PATH
}
