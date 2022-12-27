# pip bash completion start
_helptext_completer()
{
    local IFS=$'\n'
    COMPREPLY=( $($PWD/helptext-completer -l "$COMP_LINE" -p $COMP_POINT -d /tmp/X -- $COMP_CWORD "${COMP_WORDS[@]}" 2>/dev/null ) )
    [ "${COMPREPLY[0]}" == "<<HT_REDIRECT>>" ] && {
        local CALL=${COMPREPLY[2]}
        COMP_CWORD=$((${COMPREPLY[1]}-1))
        COMPREPLY=("${COMPREPLY[@]:3}")
        COMP_WORDS=(${COMPREPLY[@]})
        # COMP_CWORD=$((${#COMP_WORDS[@]}))
        echo "DEBUG::: CALL=$CALL" >> /tmp/X
        echo "DEBUG::: COMP_WORDS=${COMP_WORDS[@]}" >> /tmp/X
        echo "DEBUG::: COMP_LINE=${COMP_LINE}" >> /tmp/X
        echo "DEBUG::: #COMP_WORDS=${#COMP_WORDS[@]}" >> /tmp/X
        echo "DEBUG::: COMP_CWORD=$COMP_CWORD" >> /tmp/X
        echo "DEBUG::: COMP_POINT: $COMP_POINT" >> /tmp/X
        echo "DEBUG::: COMP_KEY: $COMP_KEY" >> /tmp/X
        COMPREPLY=($($CALL))
        echo "DEBUG::: COMPREPLY=${COMPREPLY[@]}" >> /tmp/X
        return
    }
}

_pip_version ()
{
    echo "DEBUG::: COMP_CWORD: [$COMP_CWORD]" >> /tmp/X
    echo "DEBUG::: CURWORD   : [${COMP_WORDS[$COMP_CWORD]}]" >> /tmp/X
    compgen -S " " -W "$(ls -1 /usr/bin/python* | grep [0-9]'$' | sed 's|^/usr/bin/||')" -- "${COMP_WORDS[$COMP_CWORD]}"
}

_pip_cert ()
{
    echo "DEBUG::: COMP_CWORD: [$COMP_CWORD]" >> /tmp/X
    echo "DEBUG::: CURWORD   : [${COMP_WORDS[$COMP_CWORD]}]" >> /tmp/X
    compgen -S " " -W "$(echo -e 'test-1.cert\ntest-2.cert')" -- "${COMP_WORDS[$COMP_CWORD]}"
}

pip-test () {
    # export HT_APP_PIP_HELPOPT=':man'
    
    export HT_REDIRECT_PIP__ANY__CERT='_pip_cert'
    export HT_REDIRECT_PIP__ANY__PYTHON='_pip_version'
    # export HT_REDIRECT_PIP_INSTALL='_test2'
    complete -o default -F _helptext_completer pip
}

pip-test