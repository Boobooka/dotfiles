#!/bin/zsh

SLEEP_TIME=2

vol() {
  amixer get Master | awk -F "[][]" 'END{ print $2,$4}' | read vol state
  mic=`amixer get Capture | awk -F "[][]" 'END{print $4}'`
  icon="󰕾"
  [[ $mic = off ]] && micoff=" +@fg=2;󰍭+@fg=0;"
  fg=3
  [[ $vol = "0%" ]] && icon="󰝟" && fg=0
  [[ $state = off ]] &&  icon="󰖁" && fg=2
  
  batt=`bluetoothctl info 00:09:B0:2C:B6:B8 | awk '{gsub (/[)(]/, "")} END{print $4}'`
  [[ -n $batt ]] && bt=" +@fg=4;󰥰+@fg=0; $batt%"    
   
  echo -e "+@fg=$fg;$icon+@fg=0; $vol$micoff$bt"
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
 
  echo -e "+@fg=3;+@fg=0; $cpu%"
}

mem() {
  free | awk '/Mem/ {print $2,$3}' | read total used
  p=0; (( p += (used / (total / 100)) ))
  pre=""
  me="MiB"
  if ((p > 90)) {
    pre="+@fg=2;" 
  }
  post="+@fg=0;"
  (( used /= 1024))
  echo -e "+@fg=3;$post $used $me ($pre$p%$post)"
}

hdd() {
  DF=`df -h`
  echo $DF | awk '/\/$/ {print $4,$5}' | read r_free r_perc
  echo $DF | awk '/\/home$/ {print $4,$5}' | read h_free h_perc
  echo -e "+@fg=3;󱂵+@fg=0; $h_free ($h_perc) +@fg=3;+@fg=0; $r_free ($r_perc)"
}	

while :; do
  echo -e "$(hdd) $(cpu) $(mem) $(vol)"
  sleep $SLEEP_TIME
done
