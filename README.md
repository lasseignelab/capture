CAPTURE
A framework and command line interface (CLI) for computational science.

Table of Contents
- [Installation](#installation)
- [CLI usage](#cli-usage)
  - [cap env](#env)
  - [cap help](#help)
  - [cap md5](#md5)
  - [cap new](#new)
  - [cap run](#run)
    - [Runtime environment](#runtime-environment)
  - [cap update](#update)
  - [cap version](#version)
- [Job helper functions](#job-helper-functions)
  - [cap_array_value](#cap_array_value)
  - [cap_data_download](#cap_data_download)
- [Environment helper functions](#environment-helper-functions)
  - [cap_data_link](#cap_data_link)

# Installation
```
curl -sSL https://raw.githubusercontent.com/lasseignelab/capture/refs/heads/main/install.sh | bash
source ~/.bash_profile
```
# Update to the current version
```
cap update
```
# CLI usage
The `cap` CLI provides commands to help with reproducible research.
```
cap <command> params...
```
## env
Displays CAPTURE environment variables.

Definition:
```
cap env
```
Example:
```
$ cap env

CAP_CONDA_PATH=/data/user/acrumley/3xtg-repurposing/bin/conda
CAP_CONTAINER_PATH=/data/user/acrumley/3xtg-repurposing/bin/docker
CAP_DATA_PATH=/data/user/acrumley/3xtg-repurposing/data
CAP_ENV=default
CAP_LOGS_PATH=/data/user/acrumley/3xtg-repurposing/logs
CAP_PROJECT_NAME=3xtg-repurposing
CAP_PROJECT_PATH=/data/user/acrumley/3xtg-repurposing
CAP_RANDOM_SEED=16600
CAP_RESULTS_PATH=/data/user/acrumley/3xtg-repurposing/results
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

  Usage: cap COMMAND ...

  Commands:
    The following subcommands are available.

  COMMAND
    env        Displays CAPTURE environment variables.
    help       Shows help for the cap command line tool.
    md5        Calculates a combined MD5 checksum for one or more files.
    new        Creates a new reproducible research project.
    run        Runs a CAPTURE framework job.
    update     Updates the CAPTURE framework to the latest version.
    version    Displays the currently installed version of CAPTURE.

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
cap new [options] PROJECT_NAME

PROJECT_NAME Name of the project which will be used for the directory name.
			 It should also match the git host repo name if one is used.

Options:

--git-host=<host-domain-name>
		   Git host for the repository used for creating git remotes.  The
		   default is "github.com".
-o,--owner=<owner-id>
		   Git host owner the project repo will be created under.  This may
		   be a personal or organization account.
--skip-git
		   Skip making the project a git repository in order to allow
		   the use of other source control software.

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

View job output with the following command:
cat logs/01_down_20241118_090854_tcrumley*

Submitted batch job 29818073
```
### Runtime environment

The runtime environment is configured with the following variables available
to Slurm scripts.
- **CAP_PROJECT_NAME**: The name of the project given with the `cap new`
command.
- **CAP_ENV**: The name of the current execution environment.  Defaults to
the value "default".  A shell script in `config/environments` with a name
matching the environment name will be executed during the CAPTURE configuration
process, e.g. `config/environments/default.sh`.  This variable will generally
be set in the `~/.caprc` file.  It is possible to set it as a shell environment
variable somewhere like `~/.bash_profile`.  Another option is to provide it
before a command, e.g. `CAP_ENV=mylab cap run foo.sh`.  Finally, some commands
provide an option for environment such as `cap run --environment=mylab foo.sh`.
- **CAP_PROJECT_PATH**: Path to the root directory of the project.
- **CAP_LOGS_PATH**: Path to where log files will be written.  Defaults to
`<project-path>/logs`.
- **CAP_DATA_PATH**: Path to where data files will be written.  Defaults to
`<project-path>/data`.
- **CAP_RESULTS_PATH**: Path to where analysis results will be written.
Defaults to `<project-path>/results`.
- **CAP_CONTAINER_PATH**: Path to where container files such as Docker will be
maintained.  Defaults to `<project-path>/bin/docker`.
- **CAP_CONDA_PATH**: Path to where conda files will be maintained.  Defaults
to `<project-path>/bin/conda`.
- **CAP_RANDOM_SEED**: A randomly generated seed to facilitate reproducible
random number generation.

Environment variables can be configured with the following configuration files.
```
/
|-- etc/
`   |-- caprc

~/
`-- .caprc

<project-path>/
|-- .caprc
|-- config/
|   |-- pipeline.sh
|   `-- environment/
|       |-- default.sh
`       `-- <lab-name>.sh
```
Configuration files are loaded in the following order:
- **\<project-path\>/config/pipeline.sh**: Configuration to bootstrap the
runtime environment. This file is configured by the `cap new` command with the
`CAP_PROJECT_NAME` variable set to the name given as a parameter.
- **defaults**: The defaults described in the environment variable section
are set at this point.
- **/etc/caprc**: Configuration set by an organization.
- **~/.caprc**: Configuration set for a specific user. This is a good place
to `source` in lab specific configuration.
- **\<project-path\>/.labrc**: Configuration specific to a project.
- **\<project-path\>/config/environments/<CAP_ENV>.sh**: Configuration specific
to a project and the environment it is being executed in. The `default.sh`
configuration should only contain reproducible configuration that will work in
any Slurm environment. Other lab specific environment files can contain non-
reproducible configuration but the job must also work in the default environment
for reproducibility. An example of environment specific configuration would be
creating symlinks in the data directory for sharing large datasets internal to
a lab while also downloading the data when the symlink does not exist. See
[cap_data_link](#cap_data_link).

## update
The `cap update` command will upgrade the CAPTURE framework to the latest
version.

Definition:
```
cap update
```
Example:
```
$ cap update


Switched to branch 'main'
Already up-to-date.

CAPTURE updated to version v0.0.1.
```

## version
The `cap version` command will display the currently installed version
of CAPTURE.

Definition:
```
cap version
```
Example:
```
$ cap version

v0.0.3

```
# Job helper functions
## cap_array_value
Retrieves a value from an array file based on a zero based index.
```
cap_array_value FILE [INDEX]
```
- `FILE` The file containing an array value on each line.
- `INDEX` The optional zero based index for the value of the array.

If a value is not provided for `INDEX` then the SLURM_ARRAY_TASK_ID
environment variable will be used as the default.

Example that retrieves array values based on the Slurm environment
variable default index.
```
sample=$(cap_array_value "$CAP_DATA_PATH/sample_list.array")
```

Example with a `for` loop:
```
for index in {1..10}; do
  sample=$(cap_array_value "$CAP_DATA_PATH/sample_list.array" index)
  # Do something with each sample value.
done
```

## cap_data_download
Downloads data into the data directory.
```
cap_data_download [options] URL
```
- `URL` The URL of the file to download.

Options
- `--md5sum` The md5sum to check against the file being downloaded.

The file will be downloaded with the same name as specified by the URL.  If the
file is a TAR file then it will be unarchived into the data directory.  The
data directory is specified by `CAP_DATA_PATH` which defaults to
`CAP_PROJECT_PATH/data`.

If the file or directory already exists in the `data` directory then it will
not be downloaded again. This is also true when the file or directory has
been symlinked into the `data` directory by [cap_data_link](#cap_data_link).

The following example will download and unarchive a directory into
`CAP_DATA_PATH/refdata-gex-GRCm39-2024-A`.
```
cap_data_download \
  --md5sum="37c51137ccaeabd4d151f80dc86ce0b3" \
  "https://cf.10xgenomics.com/supp/cell-exp/refdata-gex-GRCm39-2024-A.tar.gz"
```

# Environment helper functions
Functions to facilitate setting up environments for CAPTURE to operate in.
Environments help create reproducible pipelines by allowing authors to
work in their unique development setup, which may only work for them, and
reviewers to run pipelines in a default environment that should work anywhere.
Environment files are stored in the `config/environments` directory.

## cap_data_link
Creates a symbolic link in the data directory. A common use is to prevent
duplicate storage of large datasets in the author's compute environment. By
linking to a shared copy, multiple authors won't create multiple copies. This
function is often used in conjunction with
[cap_data_download](#cap_data_download).
```
cap_data_link <FILE>|<DIR>
```
- `<FILE>|<DIR>` The full path to a file or directory.

The symbolic link will have the same name as the specified file or directory
and will be created in the directory specified by `CAP_DATA_PATH` which
defaults to `CAP_PROJECT_PATH/data`.

The following example will create a symbolic link at `$CAP_DATA_PATH/mouse`
and should be included in an environment file in `config/environments`, e.g
`config/environments/my_lab.sh`. The `$MY_LAB` environment variable should
be created in a `.caprc` file (See [Runtime environment](#runtime-environment)).
```
cap_data_link "$MY_LAB/genome/mouse"
```
To use the `my_lab` environment when running a job, use the `cap run` command
with the -e/--environment option like in the following example.
```
cap run -e my_lab src/01_download.sh
```
