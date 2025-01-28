#!/bin/bash

# Function to handle tab completion for CAPTURE
_cap_completion() {
	local current subcommand subcommands
	current="${COMP_WORDS[COMP_CWORD]}"
	subcommand="${COMP_WORDS[1]}"
	subcommands="env help md5 new run update version"

  if [[ "${COMP_CWORD}" -eq 1 ]]; then
		# Show the cap subcommand list.
    mapfile -t COMPREPLY < <(compgen -W "${subcommands}" -- "${current}")
  else
		case "$subcommand" in
			"help")
				# Show the cap subcommand list.
				if [[ "${COMP_CWORD}" == 2 ]]; then
					mapfile -t COMPREPLY < <(compgen -W "${subcommands}" -- "${current}")
				fi
				;;
			"md5"|"run")
				# Tab compete with file and directory names.
				compopt -o default -o plusdirs
				;;
			*)
				# Don't tab complete.
				COMPREPLY=()
		esac
  fi
}

# Register the completion function for "mytool"
complete -F _cap_completion cap

