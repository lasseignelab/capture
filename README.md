# lab-cli
A command line interface for computational lab work.

# Installation
```
cd $USER_HOME
mkdir bin
cd bin
git clone https://github.com/lasseignelab/lab-cli.git
. lab-cli/install.sh
source ~/.bash_profile
```
# Update
```
cd $USER_HOME/bin/lab-cli
git pull origin main
```
# Usage
The `lab` CLI provides commands to help with reproducible research.
```
lab <command> params...
```

## help
Shows help for the lab command line tool.

Definition:
```
lab help [COMMAND]
```
Example:
```
$ lab help

  Commands:

  help  Shows help for the lab command line tool.
  md5   Calculates a combined MD5 checksum for one or more files.

$ lab help md5

  Calculates a combined MD5 checksum for one or more files.

  The "md5" command produces a combined MD5 checksum for all the files
  specified.  It will show a list of all files included to ensure that the
  result is as expected.

  Usage:
    lab md5 FILE...

    FILE... can be one or more file and/or directory specifications.

  Example:
    $ lab md5 *

    Files included:
    43bd364a97a38fb1da7c57e6381886c1  lab-cli/LICENSE
    b794df25f796ac80680c0e4d27308bce  lab-cli/commands/md5.sh
    0d9281c3586c420130bcb5d25c8a151a  lab-cli/lab
    5e79c988140af1b7bd5735b0bf96306b  lab-cli/README.md
    783a44ffae97afbce3f1649c5ff517a5  lab-cli/install.sh

    Combined MD5 checksum:
    a225199964b84bdeef33bafe3df7c10b
```

## md5
The `lab md5` command will produce an md5sum for the file or files specified.
This makes it easy to determine whether files are identical.

Definition:
```
lab md5 FILE...
```
Example:
```
$ lab md5 *

Files included:
43bd364a97a38fb1da7c57e6381886c1  lab-cli/LICENSE
b794df25f796ac80680c0e4d27308bce  lab-cli/commands/md5.sh
0d9281c3586c420130bcb5d25c8a151a  lab-cli/lab
5e79c988140af1b7bd5735b0bf96306b  lab-cli/README.md
783a44ffae97afbce3f1649c5ff517a5  lab-cli/install.sh

Combined MD5 checksum:
a225199964b84bdeef33bafe3df7c10b
```
