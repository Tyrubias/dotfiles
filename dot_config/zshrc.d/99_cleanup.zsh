if [[ -n "${PATH}" ]]; then
  old_PATH=:${PATH}
  PATH=
  while [[ -n "${old_PATH}" ]]; do
    x=${old_PATH##*:} # the last remaining entry
    case ${PATH} in
      *:"${x}":*) ;;        # already there
      *) PATH=${x}:${PATH} ;; # not there yet
    esac
    old_PATH=${old_PATH%:*}
  done
  PATH=${PATH#:}
  PATH=${PATH%:}
  unset old_PATH x
fi
