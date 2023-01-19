___HT_TTY=$(tty)
___HT_DEBUG="/tmp/X"
[ -n "$___HT_DEBUG" ] && ___HT_DEBUG_REDIRECT=">> $___HT_DEBUG"

_helptext_completer()
{
    local IFS=$'\n'
    COMPREPLY=( $(COLUMNS=$COLUMNS helptext-completer -t "$___HT_TTY" -l "$COMP_LINE" -p $COMP_POINT -d "$___HT_DEBUG" -- $COMP_CWORD "${COMP_WORDS[@]}" 2>/dev/null ) )
    [ "${COMPREPLY[0]}" == "<<HT_REDIRECT>>" ] && {
        local CALL=${COMPREPLY[2]}
        COMP_CWORD=${COMPREPLY[1]}
        COMPREPLY=("${COMPREPLY[@]:3}")
        COMP_WORDS=(${COMPREPLY[@]})
        COMPREPLY=($($CALL))
    }
    echo "DEBUG:::  $CALL returned: [${COMPREPLY[@]}]" >> $___HT_DEBUG
    for i in ${COMPREPLY[@]} ; do 
        echo "DEBUG::: Result item from $CALL: " $i >> $___HT_DEBUG
    done
}

_helptext_completer_wrap_prepare() {
    local IFS=$'\n'
    [ "$COMP_CWORD" == 1 ] && {
        COMPREPLY=($(compgen -c -- "${COMP_WORDS[$COMP_CWORD]}"))
        return 0
    }

    COMP_WORDS=("${COMP_WORDS[@]:1}")
    COMP_CWORD=$((COMP_CWORD-1))
    COMP_LINE=${COMP_LINE/#htc /}
    COMP_LINE=${COMP_LINE/#ht /}
    COMP_POINT=$((COMP_POINT-3))
    set -o posix ; set | grep ^COMP | perl -pe '$_.="DEBUG::: " ' >> $___HT_DEBUG

    return 1
}

_helptext_completer_wrap()
{
    _helptext_completer_wrap_prepare ht && return
    COLUMNS=$COLUMNS HT_HELPOPT=:man HT_NO_COMMANDS=1 HT_SHOW_MORE=1 _helptext_completer
}

_helptext_completer_wrap_cmds()
{
    _helptext_completer_wrap_prepare htc && return
    COLUMNS=$COLUMNS HT_HELPOPT=:man HT_SHOW_MORE=1 _helptext_completer
}

_helptext_completer_completion() {
    echo "DEBUG::: ${COMP_WORDS[$COMP_CWORD]}" >> $___HT_DEBUG
    compgen -S ' ' -W "$(echo -e 'bash\nzsh')" -- "${COMP_WORDS[$COMP_CWORD]}"
}

ht  () { "$@"; }
htc () { "$@"; }

export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__COMPLETION=_helptext_completer_completion
export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__S=_helptext_completer_completion
export HT_APP_HELPTEXT_COMPLETER_NOCOMMANDS=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_ALL=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_MORE=1

complete -o default -o nosort -F _helptext_completer helptext-completer
complete -o default -o nosort -F _helptext_completer_wrap  ht  -A command
complete -o default -o nosort -F _helptext_completer_wrap_cmds htc -A command

