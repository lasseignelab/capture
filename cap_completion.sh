# Function to handle tab completion for CAPTURE
_cap_completion() {
	local currrent subcommand subcommands
	current="${COMP_WORDS[COMP_CWORD]}"
	subcommand="${COMP_WORDS[1]}"
	subcommands="env help md5 new run update verify version"

  if [[ "${COMP_CWORD}" -eq 1 ]]; then
		# Show the cap subcommand list.
    COMPREPLY=( $(compgen -W "${subcommands}" -- "${current}") )
  else
		case "$subcommand" in
			"help")
				# Show the cap subcommand list.
				if [[ "${COMP_CWORD}" == 2 ]]; then
					COMPREPLY=( $(compgen -W "${subcommands}" -- "${current}") )
				fi
				;;
			"md5"|"run"|"verify")
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

