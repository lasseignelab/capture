setup_suite() {
  # Make sure the `cap` command in this CAPTURE code base is used in tests
  # instead of the one installed in the system.
  PATH="$(pwd):$PATH"
  export PATH

  # Location of the CAPTURE framework development environment.
  CAP_DEVELOPMENT_PATH="$(pwd)"
  export CAP_DEVELOPMENT_PATH

  # Setup a unique temporary directory for BATS tests to fix temporary file
  # errors on Cheaha where developers share temp directories.
  BATS_TMPDIR="$(mktemp -d)"
  export BATS_TMPDIR

  # Setup test locations for caprc files.  Otherwise, the developer's actual
  # caprc files will be used and make tests fail.
  CAP_ETC_RC_PATH="$(mktemp -p "$BATS_TMPDIR")"
  export CAP_ETC_RC_PATH
  CAP_HOME_RC_PATH="$(mktemp -p "$BATS_TMPDIR")"
  export CAP_HOME_RC_PATH
}

teardown_suite() {
  # Remove the unique temporary directory created in setup_suite().
  rm -rf "$BATS_TMPDIR"
}
