setup_suite() {
  # Make sure the `cap` command in this CAPTURE code base is used in tests
  # instead of the one installed in the system.
  PATH="$(pwd):$PATH"
  export PATH
}