tputter () 
{ 
    ps faux | grep --color=auto -v grep | grep --color=auto -B 1 -E "_ (stty |cat /tmp/htext.$USER|tee /tmp/htext.$USER)"
}
tputter-bash () 
{ 
    tputter | grep --color=auto bash | awk '{print $2}'
}
tputter-kill () 
{ 
    tputter-ps | xargs kill -9 2>/dev/null
}
tputter-ps () 
{ 
    tputter | grep --color=auto -E '_ (bash|cat|stty|tee)' | awk '{print $2}'
}
tputter-tree () 
{ 
    for i in $(tputter-ps);
    do
        pstree -TpsH $i $i;
    done
}
tputter-tty () 
{ 
    for i in $(tputter-ps);
    do
        ls --color=auto -l /proc/$i/fd/0;
    done
}
tputter-ttys () 
{ 
    for i in $(tputter-ps);
    do
        ls --color=auto -l /proc/$i/fd/0;
    done | grep --color=auto -Eo '/dev.*' | sort -u
}
optstty () 
{ 
    stty -a | sed -r 's/ = /=/g;s/(speed|rows|columns) ([^\s]+) /\1=\2 /g;s/ baud//;s/;/ /g' | tr ' ' "\n" | grep --color=auto -Ev '^$'
}
optstty-global () 
{ 
    optstty | grep --color=auto -E '='
}
optstty-off () 
{ 
    optstty | grep --color=auto -E '^-'
}
optstty-on () 
{ 
    optstty | grep --color=auto -Ev '^-|='
}
quote () 
{ 
    local quoted=${1//\'/\'\\\'\'};
    printf "'%s'" "$quoted"
}
quote_readline () 
{ 
    local quoted;
    _quote_readline_by_ref "$1" ret;
    printf %s "$ret"
}
optstty-stats () 
{   
    optstty-on > /tmp/ttyon$1
    optstty-off > /tmp/ttyoff$1
    optstty-global > /tmp/ttyglob$1
}
