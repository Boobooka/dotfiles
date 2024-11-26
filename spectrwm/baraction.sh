#!/bin/zsh

SLEEP_TIME=2

vol() {
  vol=`amixer get Master | awk -F "[][]" 'END{ print $4,$2}'`
  #echo -e "\U1F50A $vol"
  echo -e "+@fg=3;Vol: $vol+@fg=0;"
}

cpu() {
  read cpu a b c previdle rest < /proc/stat
  prevtotal=$((a+b+c+previdle))
  sleep 0.5
  read cpu a b c idle rest < /proc/stat
  total=$((a+b+c+idle))
  totaldiff=$((total-prevtotal))
  idlediff=$((idle-previdle))
  cpu=$(( 100 * (totaldiff - idlediff) / totaldiff ))
 
  echo -e "Cpu: $cpu%"
}

mem() {
  free | awk '/Mem/ {print $2,$3}' | read total used
  p=0; (( p += (used / (total / 100)) ))
  if ((p > 90)) {
    pre="+@fg=2;"; post="+@fg=0;"
  } else { 
    pre=""; post=""
  }
  (( used /= 1024))
  echo -e "Mem: $used MiB ($pre$p%$post)"
}

hdd() {
  df -h | awk 'NR==5 {print $3,$5}' | read used perc
  echo -e "Hdd: $used ($perc)"
}	

while :; do
	echo -e "$(hdd)|$(cpu)|$(mem)|$(vol)"
  sleep $SLEEP_TIME
done	
