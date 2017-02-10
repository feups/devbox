#!/usr/bin/env bash
set -o pipefail
set -e

zone=$1

_pep_completion () {
    local nodes=$(cat "$HOME/.local/share/cicd/.nodes-${zone}")
    COMPREPLY=( $(compgen -W "$nodes" -- ${COMP_WORDS[COMP_CWORD]}) )
    return 0
}

_hostgroup_completion () {
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    case "${prev}" in
        "-n")
          COMPREPLY=( $(compgen -W "middleware bos nova gis brucat django fidus iam irisbox plone tms" -- ${COMP_WORDS[COMP_CWORD]}) )
          return 0
    ;;
    esac
}

_help_topic () {
    COMPREPLY=( $(compgen -W "wheel runner execution" -- ${COMP_WORDS[COMP_CWORD]}) )
    return 0
}

_help_completion () {
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        runner)
            local doc=$(cat ".doc-runner")
            COMPREPLY=( $(compgen -W "$doc" -- ${cur}) )
            return 0
            ;;
        wheel)
            local doc=$(cat ".doc-wheel")
            COMPREPLY=( $(compgen -W "$doc" -- ${cur}) )
            return 0
            ;;
        execution)
            local doc=$(cat ".doc-execution")
            COMPREPLY=( $(compgen -W "$doc" -- ${cur}) )
            return 0
            ;;
        *)
            COMPREPLY=( $(compgen -W "wheel runner execution" -- ${cur}) )
            return 0
            ;;
    esac
}
complete -F _pep_completion pep data runpuppet du facts
complete -F _hostgroup_completion facts
complete -F _help_topic commands-for
complete -F _help_completion help-for
