CAPTURE
A framework and command line interface (CLI) for computational science.

# Installation
```
curl -sSL https://raw.githubusercontent.com/lasseignelab/capture/refs/heads/main/install.sh | bash
source ~/.bash_profile
```
# Update
```
cd ~/bin/capture
git pull
git submodule update --init --recursive
```
# Usage
The `cap` CLI provides commands to help with reproducible research.
```
cap <command> params...
```

## help
Shows help for the cap command line tool.

Definition:
```
cap help [COMMAND]
```
Example:
```
$ cap help

  Commands:

  help  Shows help for the cap command line tool.
  md5   Calculates a combined MD5 checksum for one or more files.

$ cap help md5

  Calculates a combined MD5 checksum for one or more files.

  The "md5" command produces a combined MD5 checksum for all the files
  specified.  It will show a list of all files included to ensure that the
  result is as expected.

  Usage:
    cap md5 FILE...

    FILE... can be one or more file and/or directory specifications.

  Example:
    $ cap md5 *

    Files included:
    43bd364a97a38fb1da7c57e6381886c1  capture/LICENSE
    b794df25f796ac80680c0e4d27308bce  capture/commands/md5.sh
    0d9281c3586c420130bcb5d25c8a151a  capture/lab
    5e79c988140af1b7bd5735b0bf96306b  capture/README.md
    783a44ffae97afbce3f1649c5ff517a5  capture/install.sh

    Combined MD5 checksum:
    a225199964b84bdeef33bafe3df7c10b
```

## md5
The `cap md5` command will produce an md5sum for the file or files specified.
This makes it easy to determine whether files are identical.

Definition:
```
cap md5 FILE...
```
Example:
```
$ cap md5 *

Files included:
43bd364a97a38fb1da7c57e6381886c1  capture/LICENSE
b794df25f796ac80680c0e4d27308bce  capture/commands/md5.sh
0d9281c3586c420130bcb5d25c8a151a  capture/lab
5e79c988140af1b7bd5735b0bf96306b  capture/README.md
783a44ffae97afbce3f1649c5ff517a5  capture/install.sh

Combined MD5 checksum:
a225199964b84bdeef33bafe3df7c10b
```

## new
The `cap new` command will create a new research project based on the
project-template submodule in the capture repository.  The project
repository will be created with the origin remote pointed to a Github
repository owner specified by the Github account and project name parameters.

Definition:
```
cap new GITHUB_OWNER PROJECT_NAME

GITHUB_OWNER Github owner the project repo will be created under.  This may
             be a personal or organization account.
PROJECT_NAME Name of the project which will match the Github repo name.
```
Example:
```
$ cap new lasseignelab PKD_Research

Create an empty repository for 'PKD_Research' on GitHub by using the
following link and settings:

  https://github.com/organizations/lasseignelab/repositories/new

  * No template
  * Owner: lasseignelab
  * Repository name: PKD_Research
  * Private
  * No README file
  * No .gitignore
  * No license

Where you able to create a repository (y/N)? y


Cloning into 'PKD_Research'...
done.

...

Happy researching!!!
```
## run
The `cap run` command runs a CAPTURE framework job within the context of a
reproducible research project.  It will configure the environment based
on configuration defined by the current user.

Definition:
```
cap run [options] FILE

FILE  File name of the job to run.

Options:

-e,--environment
           Specifies the environment to run jobs in.  Environments allow
           different setups for a pipeline.  For instance, a pipeline may
           use internal copies of data during development but download that
           data when the pipeline is ran in a different environment.
-n,--dry-run
           Displays the contents of the job to run along with the context
           it will run in.
```
Example:
```
$ cap run src/01_download.sh
Submitted batch job 29818073
```
