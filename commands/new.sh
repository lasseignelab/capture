#!/bin/bash

cap_new_description() {
  cat <<EOF
  Creates a new reproducible research project.
EOF
}

cap_new_help() {
  cap_new_description
  echo

  cat <<EOF
  The "new" command produces a new reproducible research project based on
  a project template that adheres to a set of conventions.  The conventions
  include a directory structure, Github actions, and stubbed out files.

  Usage:
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

  Example:
    $ cap new --owner lasseignelab PKD_Research

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
EOF
}

cap_new() {
  cap_new_parse_commandline_parameters "$@"

  # If the project directory exists then abort.
  if [ -d "$project_name" ]; then
    echo "Error: The directory '$project_name' already exists."
    return 1
  fi

  if [[ "$skip_git" != "true" && -n "$owner" ]]; then
    cap_new_verify_git_ssh_configuration
    cap_new_create_git_host_repository
  fi

  # Find the CAPTURE framework installion directory.
  installed_directory=$(dirname "$(command -v cap)")

  # Clone, configure, and push the project.
  echo
  git clone "$installed_directory"/project-template "$project_name"
  cd "$project_name" || echo "Error: Directory '$project_name' does not exist."

  if [ -d ".git" ]; then
    rm -rf .git
    if [[ "$skip_git" == "true" ]]; then
      rm -rf .github
      rm .gitignore
      rm logs/.gitignore
    else
      git init
      cap_new_add_pipeline_config_file
      cap_new_add_dockerfile_file
      git add .
      git commit -m "Initial commit"
      git branch -m master main
      if [[ -n "$owner" ]]; then
        git remote add origin git@"$git_host":"$owner"/"$project_name".git
        git push origin main
      fi
    fi

    echo
    echo "Happy researching!!!"
    echo
  fi
}

cap_new_add_dockerfile_file() {
  temporary_file=$(mktemp)

  latest_release=$(
    curl -s https://hub.docker.com/v2/repositories/bioconductor/bioconductor_docker/tags | \
      jq -r '.results[].name' | \
      grep -E '^RELEASE_' | \
      sort | \
      tail -n 1
  )

  sed \
    -e "s/{{bioconductor_version}}/${latest_release}/g" \
    bin/docker/Dockerfile > "$temporary_file"

  mv "$temporary_file" bin/docker/Dockerfile
}

cap_new_add_pipeline_config_file() {
  temporary_file=$(mktemp)
  random_seed="$RANDOM"

  sed \
    -e "s/{{project_name}}/${project_name}/g" \
    -e "s/{{random_seed}}/${random_seed}/g" \
    config/pipeline.sh > "$temporary_file"

  mv "$temporary_file" config/pipeline.sh
}

cap_new_create_git_host_repository() {
  # Prompt the researcher to create a repository on their git host
  case "$git_host" in
    "github.com")
      cat <<EOF

Create an empty repository for '$project_name' on GitHub by using the
following link and settings:

  https://github.com/organizations/$owner/repositories/new

  * No template
  * Owner: $owner
  * Repository name: $project_name
  * Private
  * No README file
  * No .gitignore
  * No license

EOF
      ;;
    "gitlab.com")
      cat <<EOF

Create an empty repository for '$project_name' on GitLab by using the
following link and settings:

  https://gitlab.com/projects/new#blank_project

  * Project name: $project_name
  * Project URl group: $owner
  * Project slug: $project_name
  * No deployment target
  * Private
  * No README file

EOF
      ;;
    *)
      cat <<EOF

Create an empty repository named $project_name at $git_host.

EOF
  esac

  echo -n "Where you able to create a repository (y/N)? "
  read -r response
  response=${response,,}
  echo
  if [[ "$response" != "y" ]]; then
    echo "New project creation aborted."
    echo
    exit 0
  fi
}

cap_new_parse_commandline_parameters() {
  # Define the named commandline options
  if ! OPTIONS=$(getopt -o o: --long owner:,git-host:,skip-git -- "$@"); then
    echo "Use the 'cap help new' command for detailed help."
    exit 1
  fi
  eval set -- "$OPTIONS"

  # Set default values for the named parameters
  owner=""
  git_host="github.com"
  skip_git=false

  # Parse the optional named command line options
  while true; do
    case "$1" in
      -o|--owner)
        owner="$2"
        shift 2 ;;
      --git-host)
        git_host="$2"
        shift 2 ;;
      --skip-git)
        skip_git=true
        shift ;;
      --)
        shift
        break;;
    esac
  done

  # Check that the required project name parameter was provided
  if [ "$#" -ne 1 ]; then
    echo "Error: incorrect number of parameters"
    echo "Usage: cap new [options] PROJECT_NAME"
    echo "Use the 'cap help new' command for detailed help."
    exit 1
  fi
  project_name=$1
}

cap_new_verify_git_ssh_configuration() {
  # If Github SSH is not configured then abort.
  if ssh -T git@"$git_host" 2>&1 | grep -q 'Permission denied'; then
    case "$git_host" in
      "github.com")
        github_docs="https://docs.github.com/en"
        github_ssh_docs="$github_docs/authentication/connecting-to-github-with-ssh"
        cat <<EOF

Github SSH is not configured or there's an issue. Please configure SSH keys
for Github before proceeding.

To setup SSH for connecting to Github do the following steps:
  1) Check for existing SSH keys:
     $github_ssh_docs/checking-for-existing-ssh-keys
  2) If no key exists, generate a new SSH key:
     $github_ssh_docs/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  3) Add a new SSH key to your github user account:
     $github_ssh_docs/adding-a-new-ssh-key-to-your-github-account

EOF
        ;;
      "gitlab.com")
        cat <<EOF

Gitlab SSH is not configured or there's an issue. Please configure SSH keys
for Gitlab before proceeding.

EOF
        ;;
      *)
        cat <<EOF

SSH for $git_host is not configured or there's an issue. Please configure SSH
keys before proceeding.

EOF
        ;;
    esac
    exit 1
  fi
}

