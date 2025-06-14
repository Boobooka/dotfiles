#!/bin/zsh

################################
###          Colors          ###
################################

# should get 2 parameters text and color
color() {
  local colors=(active alert icon bt weather) # Anything else will get the default color (0)
  echo -e "+@fg=${colors[(I)$2]};$1+@fg=0;"  
}

################################
###          Icons           ###
################################

# getIcon
gI() {
  typeset -A icons
  local icons=(
    "monitor"   "\Uf0379" # 󰍹
    "home"      "\Uf10b5" # 󱂵
    "root"      "\Uf17c"  # 
    "cpu"       "\Uf4bc"  # 
    "mem"       "\Ue266"  # 
    "vol"       "\Uf057e" # 󰕾
    "vol0"      "\Uf057f" # 󰕿
    "vol-mute"  "\Uf0581" # 󰖁
    "mic-mute"  "\Uf036d" # 󰍭
    "bt"        "\Uf0970" # 󰥰 bluetooth headset
  )
  echo -e "$(color $icons[$1] ${2:=icon})"
}


vol() {
  amixer get Master | awk -F "[][]" 'END{ print $2,$4}' | read vol state
  mic=`amixer get Capture | awk -F "[][]" 'END{print $4}'`
  batt=`bluetoothctl info 00:09:B0:2C:B6:B8 | awk -F "[)(]" '/Battery/ {print $2}'`

  [[ $vol = "0%" ]] && icon=$(gI vol0 def) || icon=$(gI vol)
  [[ $state = off ]] && icon=$(gI vol-mute alert)
  [[ $mic = off ]] && micoff=" $(gI mic-mute alert)"
  [[ -n $batt ]] && bt=" $(gI bt bt) $batt%"

  echo -e "$icon $vol$micoff$bt"
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
 
  echo -e "$(gI cpu) $cpu%"
}

mem() {
  free | awk '/Mem/ {print $2,$3}' | read total used
  p=0; (( p += (used / (total / 100)) ))
  (( p > 90 )) && p=$(color "$p%" alert) || p="$p%"
  (( used /= 1024))
  
  echo -e "$(gI mem) $used MiB ($p)"
}

hdd() {
  DF=`df -h`
  echo $DF | awk '/\/$/ {print $4,$5}' | read r_free r_perc
  echo $DF | awk '/\/home$/ {print $4,$5}' | read h_free h_perc

  echo -e "$(gI home) $h_free ($h_perc) $(gI root) $r_free ($r_perc)"
}

clk() {
  date "+%Y %b %d.%a %R"
}

weather() {
  awk '{print $1,$2,$3}' ~/.config/weather.txt | read i_moon temp i_cond
  txt="+@fn=1;$i_moon+@fn=0; $temp +@fn=1;$i_cond+@fn=0;"
  echo -e "$(color $txt weather)"
}

while :; do
  echo -e "+|2L$(gI monitor) +N:+I +S +L (+w|+M) +|C<+W> +|2R$(hdd) $(cpu) $(mem) $(vol) +|T$(weather)+|T$(clk)"
  sleep 1
done
