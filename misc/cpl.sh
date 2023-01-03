TTY="-F /dev/pts/1 "
TTY=

__tputter () {
    # local IFS=$'\n'
    while true ; do 
        echo "DEBUG::: TPUTTER: $$ $PPID: Reading from /tmp/htext.dnp.$$"  >> /tmp/X
        local TPUT="$(cat /tmp/htext.dnp.$$)"
        echo DEBUG::: TPUTTER: $$ $PPID TPUT CHECK "[$TPUT]" >> /tmp/X
        [ -n "$TPUT" ] && { 
            optstty-stats 3
            stty <$(tty) -a >> /tmp/X
            echo -ne '\033['$((TPUT+1))'D' >> $(tty)
            echo -ne '\033['1'C' >> $(tty)
            # tput cub $TPUT
        }
    done
}

_helptext_completer()
{
    #
    local IFS=$'\n'
    COMPREPLY=( $(helptext-completer -l "$COMP_LINE" -p $COMP_POINT -d /tmp/X -- $COMP_CWORD "${COMP_WORDS[@]}" 2>/dev/null ) )
    echo "DEBUG::: COMPLETER: REPLY[0]: [${COMPREPLY[0]}]" >> /tmp/X
    echo "DEBUG::: COMPLETER: REPLY[1]: [${COMPREPLY[1]}]" >> /tmp/X
    echo "DEBUG::: COMPLETER: REPLY[2]: [${COMPREPLY[2]}]" >> /tmp/X
    echo "DEBUG::: COMPLETER: REPLY[3]: [${COMPREPLY[3]}]" >> /tmp/X
    [ "${COMPREPLY[0]}" == "<<HT_TPUT>>" ] && {
        local REPLY=("${COMPREPLY[@]}")
        # stty sane -opost -imaxbel -echoe iutf8 min 0 time 10
        stty raw ignbrk opost iexten isig min 0 time 0 discard 14
        optstty-stats 2
        echo -n "DEBUG::: COMPLETER: FINAL REPLY: " ${REPLY[2]}${REPLY[3]}  >> /tmp/X
        # $(echo $(sleep .5; tput cub $TPUT) & ) &
        COMPREPLY=(${REPLY[2]}${REPLY[3]})
        echo "DEBUG::: COMPLETER: TPUT: [${REPLY[1]}]" >> /tmp/X
        echo "DEBUG::: COMPLETER: TPUT: WRITE TO: /tmp/htext.dnp.$$" >> /tmp/X
        echo "DEBUG::: COMPLETER: RECHECK: FINAL: REPLY[0]: [${REPLY[0]}]" >> /tmp/X
        echo "DEBUG::: COMPLETER: RECHECK: FINAL: REPLY[1]: [${REPLY[1]}]" >> /tmp/X
        echo "DEBUG::: COMPLETER: RECHECK: FINAL: REPLY[2]: [${REPLY[2]}]" >> /tmp/X
        echo "DEBUG::: COMPLETER: RECHECK: FINAL: REPLY[3]: [${REPLY[3]}]" >> /tmp/X
        echo ${REPLY[1]} | eval "tee /tmp/htext.dnp.$$ >&/dev/null & >& /dev/null"
        return
    }
    [ "${COMPREPLY[0]}" == "<<HT_REDIRECT>>" ] && {
        local CALL=${COMPREPLY[2]}
        COMP_CWORD=$((${COMPREPLY[1]}-1))
        COMPREPLY=("${COMPREPLY[@]:3}")
        COMP_WORDS=(${COMPREPLY[@]})
        COMPREPLY=($($CALL))
    }
}

. DEBUG.sh
# stty min 0 time 10
echo -n "DEBUG::: MAIN: "  >> /tmp/X; stty -a >> /tmp/X
# jobs -rl | grep -E '(__tputter|cat)' | awk '{print $2}' | xargs kill -9 >& /dev/null
rm -f /tmp/htext.dnp.$$
mkfifo /tmp/htext.dnp.$$
eval "$(declare -f __tputter); __tputter & >& /dev/null" >& /dev/null 
_helptext_completer_completion() {
    echo "DEBUG::: ${COMP_WORDS[$COMP_CWORD]}" >> /tmp/X
    compgen -S ' ' -W "$(echo -e 'bash\nzsh')" -- "${COMP_WORDS[$COMP_CWORD]}"
}
export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__COMPLETION=_helptext_completer_completion
export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__S=_helptext_completer_completion
export HT_APP_HELPTEXT_COMPLETER_NOCOMMANDS=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_ALL=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_MORE=1
complete -o default -o nosort -F _helptext_completer helptext-completer

