_helptext_completer () {
  local words cword 
  read -Ac words
  read -cn cword
  reply=( $($PWD/helptext-completer -l "$BUFFER" -p $CURSOR -d /tmp/X -- $((cword-1))  "$words[@]" ) )
  if [ $#reply = 0 ] ; then
    reply=($words[$cword]*)
  elif [ "$reply[1]" = "<<HT_REDIRECT>>" ] ; then
      local CALL=$reply[3]
      cword=$((reply[2]))
      reply=(${reply:3})
      reply=($(words=($reply[@]) cword=$cword $CALL))
      return
  fi

}

_pip_version ()
{
    ls -1 /usr/bin/python* | grep '[0-9]$' | sed 's|^/usr/bin/||'
}

pip-test () {
  export HT_REDIRECT_PIP__ANY__PYTHON='_pip_version'
  compctl -K _helptext_completer pip
}

pip-test