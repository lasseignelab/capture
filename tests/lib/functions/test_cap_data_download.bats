#!/usr/bin/env bats
load ../../../node_modules/bats-mock/stub

source "lib/functions/cap_data_download.sh"

setup() {
  CAP_DATA_PATH=$(mktemp -d -p "$BATS_TMPDIR")
  DOWNLOAD_FIXTURE_PATH="tests/fixtures/lib/functions/cap_data_download"
}

teardown() {
  rm -rf ${CAP_DATA_PATH}
}

@test "cap_data_download: URL not found" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/missing.txt https://non.existant.url/missing.txt : exit 8"

  run cap_data_download "https://non.existant.url/missing.txt"

  unstub wget

  [ "$status" -eq 1 ]
  [ "$output" == "Error: URL not found" ]
}

@test "cap_data_download: check zipped file existance" {
  cp $DOWNLOAD_FIXTURE_PATH/file.txt.tar.gz $CAP_DATA_PATH/file.txt.tar.gz

  run cap_data_download "https://some.url/file.txt.tar.gz"

  [ "$status" -eq 0 ]
  [ "$output" == "file.txt.tar.gz has already been downloaded" ]
}

@test "cap_data_download: check unzipped file existance" {
  cp $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt

  run cap_data_download "https://some.url/file.txt"

  [ "$status" -eq 0 ]
  [ "$output" == "file.txt has already been downloaded" ]
}

@test "cap_data_download: download an unzipped file" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt https://some.url/file.txt : cp $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt"

  run cap_data_download "https://some.url/file.txt"

  unstub wget

  diff $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt

  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}

@test "cap_data_download: download a zipped file" {
stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt.gz https://some.url/file.txt.gz : cp $DOWNLOAD_FIXTURE_PATH/file.txt.gz $CAP_DATA_PATH/file.txt.gz"

run cap_data_download  "https://some.url/file.txt.gz"

unstub wget

diff $DOWNLOAD_FIXTURE_PATH/file.txt.gz $CAP_DATA_PATH/file.txt.gz

[ "$status" -eq 0 ]
[ "$output" == "" ]
}

@test "cap_data_download: download a zipped file and unzip it" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt.gz https://some.url/file.txt.gz : cp $DOWNLOAD_FIXTURE_PATH/file.txt.gz $CAP_DATA_PATH/file.txt.gz"

  run cap_data_download --unzip "https://some.url/file.txt.gz"

  unstub wget

  diff $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt

  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}

@test "cap_data_download: download a tar file and unarchive it" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt.tar https://some.url/file.txt.tar : cp $DOWNLOAD_FIXTURE_PATH/file.txt.tar $CAP_DATA_PATH/file.txt.tar"

  run cap_data_download --unzip "https://some.url/file.txt.tar"

  unstub wget

  diff $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt

  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}

@test "cap_data_download: download a tar.gz file and unarchive/unzip it" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt.tar.gz https://some.url/file.txt.tar.gz : cp $DOWNLOAD_FIXTURE_PATH/file.txt.tar.gz $CAP_DATA_PATH/file.txt.tar.gz"

  run cap_data_download --unzip "https://some.url/file.txt.tar.gz"

  unstub wget

  diff $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt

  [ "$status" -eq 0 ]
  [ "$output" == "" ]
}

@test "cap_data_download: download and unzip a file with an invalid file extension" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.zip https://some.url/file.zip : cp $DOWNLOAD_FIXTURE_PATH/file.zip $CAP_DATA_PATH/file.zip"

  run cap_data_download --unzip "https://some.url/file.zip"
  
  unstub wget
  
  [ "$status" -eq 1 ]
  [ "$output" == "Error: Unsupported file extension 'file.zip'" ]
}

@test "cap_data_download md5sum: download a file with valid md5sum" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt https://some.url/file.txt : cp $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt"
  run cap_data_download --md5sum 148aac0d61e8e4f6d8111851ecca34b5 "https://some.url/file.txt"
  expected=$(cat <<EOF
$CAP_DATA_PATH/file.txt: OK
File download checksum verified!
EOF
)
echo $expected
  [ "$status" -eq 0 ]
  [ "$output" == "$expected" ]
}

@test "cap_data_download md5sum: download a file and md5sum fails" {
  stub wget "-nv --retry-connrefused -O $CAP_DATA_PATH/file.txt https://some.url/file.txt : cp $DOWNLOAD_FIXTURE_PATH/file.txt $CAP_DATA_PATH/file.txt"
  run cap_data_download --md5sum 148aac0d61e8e4f6d8111851ecca3445 "https://some.url/file.txt"
  expected=$(cat <<EOF
$CAP_DATA_PATH/file.txt: FAILED
md5sum: WARNING: 1 computed checksum did NOT match

File file.txt checksum verification failed!
The file was left in place for debugging purposes.  It will
need to be deleted before attempting another download.
EOF
)
echo $expected
  [ "$status" -eq 1 ]
  [ "$output" == "$expected" ]
}
