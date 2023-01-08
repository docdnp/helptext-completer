___HT_TTY=$(tty)
___HT_DEBUG=""

_helptext_completer()
{
    local IFS=$'\n'
    COMPREPLY=( $(helptext-completer -t "$___HT_TTY" -l "$COMP_LINE" -p $COMP_POINT -d "$___HT_DEBUG" -- $COMP_CWORD "${COMP_WORDS[@]}" 2>/dev/null ) )
    [ "${COMPREPLY[0]}" == "<<HT_REDIRECT>>" ] && {
        local CALL=${COMPREPLY[2]}
        COMP_CWORD=$((${COMPREPLY[1]}-1))
        COMPREPLY=("${COMPREPLY[@]:3}")
        COMP_WORDS=(${COMPREPLY[@]})
        COMPREPLY=($($CALL))
    }
}

_helptext_completer_wrap()
{
    local IFS=$'\n'
    [ "$COMP_CWORD" == 1 ] && {
        COMPREPLY=($(compgen -c -- "${COMP_WORDS[$COMP_CWORD]}"))
        return
    }

    COMP_WORDS=("${COMP_WORDS[@]:1}")
    COMP_CWORD=$((COMP_CWORD-1))
    COMP_LINE=${COMP_LINE/#ht /}
    COMP_POINT=$((COMP_POINT-3))

    HT_HELPOPT=:man HT_NO_COMMANDS=1 HT_SHOW_MORE=1 _helptext_completer
}

_helptext_completer_completion() {
    echo "DEBUG::: ${COMP_WORDS[$COMP_CWORD]}" >> /tmp/X
    compgen -S ' ' -W "$(echo -e 'bash\nzsh')" -- "${COMP_WORDS[$COMP_CWORD]}"
}

ht () { "$@"; }

export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__COMPLETION=_helptext_completer_completion
export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__S=_helptext_completer_completion
export HT_APP_HELPTEXT_COMPLETER_NOCOMMANDS=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_ALL=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_MORE=1

complete -o default -o nosort -F _helptext_completer helptext-completer
complete -o default -o nosort -F _helptext_completer_wrap ht -A command

