_helptext_completer () {
  local words cword 
  read -Ac words
  read -cn cword
  reply=( $(helptext-completer -l "$BUFFER" -p $CURSOR -d /tmp/X -- $((cword-1))  "$words[@]" ) )
  if [ $#reply = 0 ] ; then
    reply=($words[$cword]*)
  elif [ "$reply[1]" = "<<HT_REDIRECT>>" ] ; then
      local CALL=$reply[3]
      cword=$((reply[2]))
      reply=(${reply:3})
      reply=($(words=($reply[@]) cword=$cword $CALL))
  fi
}

_helptext_completer_completion() {
    echo -e "bash zsh"
}
export HT_REDIRECT_HELPTEXT_COMPLETER__ANY__COMPLETION=_helptext_completer_completion
export HT_APP_HELPTEXT_COMPLETER_NOCOMMANDS=1
export HT_APP_HELPTEXT_COMPLETER_SHOW_ALL=1
compctl -K _helptext_completer helptext-completer
