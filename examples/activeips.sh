#!/usr/bin/env bash

###   show active ips in the local network with rev lookup if avail.
activeips() {
  set +m
  local ipandnm=$(ip addr | awk '/inet / && ! /lo0/ && ! /127.0.0.1/ { print $2 }' | head -1 )
  if type revlookup.pl &> /dev/null; then
    (fping -a -g $ipandnm  2> /dev/null | revlookup.pl 2> /dev/null) & spinner $!;
  else
    (fping -a -A -d -g $ipandnm  2> /dev/null) & spinner $!;
  fi
  set -m
}

function spinner() {
  # make sure we use non-unicode character type locale
  # (that way it works for any locale as long as the font supports the characters)
  local LC_CTYPE=C

  local pid=$1 # Process Id of the previous running command
  local spin_type=${2:-$((RANDOM % 19))}

  case $spin_type in
  0)
    local spin='⠁⠂⠄⡀⢀⠠⠐⠈'
    local charwidth=3
    ;;
  1)
    local spin='-\|/'
    local charwidth=1
    ;;
  2)
    local spin="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"
    local charwidth=3
    ;;
  3)
    local spin="▉▊▋▌▍▎▏▎▍▌▋▊▉"
    local charwidth=3
    ;;
  4)
    local spin='←↖↑↗→↘↓↙'
    local charwidth=3
    ;;
  5)
    local spin='▖▘▝▗'
    local charwidth=3
    ;;
  6)
    local spin='┤┘┴└├┌┬┐'
    local charwidth=3
    ;;
  7)
    local spin='◢◣◤◥'
    local charwidth=3
    ;;
  8)
    local spin='◰◳◲◱'
    local charwidth=3
    ;;
  9)
    local spin='◴◷◶◵'
    local charwidth=3
    ;;
  10)
    local spin='◐◓◑◒'
    local charwidth=3
    ;;
  11)
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local charwidth=3
    ;;
  12)
    local spin='░▒▓█▓▒'
    local charwidth=3
    ;;
  13)
    local spin='☉◎◉●◉'
    local charwidth=3
    ;;
  14)
    local spin='⚬⚭⚮⚯'
    local charwidth=3
    ;;
  15)
    local spin='䷀䷍䷈䷉䷌'
    local charwidth=3
    ;;
  16)
    local spin='䷀䷍䷙䷨䷩䷘䷌'
    local charwidth=3
    ;;
  17)
    local spin='䷀䷍䷈䷉䷌䷉䷈䷍'
    local charwidth=3
    ;;
  18)
    local spin='䷀䷍䷥䷤䷌䷤䷥䷍'
    local charwidth=3
    ;;
  esac

  local i=0
  tput civis # cursor invisible
  while kill -0 $pid 2>/dev/null; do
    local i=$(((i + $charwidth) % ${#spin}))
    printf "%s" "${spin:$i:$charwidth}"
    tput cub1
    sleep .1
  done

  tput cnorm
  wait $pid # capture exit code
  return $?
}


activeips

