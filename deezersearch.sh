#!/bin/sh

#guicmd='bemenu -m $(/home/user/.local/bin/swayfocus) -i --hb #4c566a --hf #88c0d0 --nf #eceff4 --nb #2e3440 --fb #2e3440 --fn Cantarell 14 --tb #2E3440 --tf #5E81AC'
guicmd='fzf --no-info --height=6'

[ -z $1 ] && type=$(echo -e "track\nalbum\nplaylist" | $guicmd ) || type="$1"
[ -z $type ] && exit
#query=$(echo | $guicmd)

echo -n "Search: "
read query

query=$(sed \
	-e 's| |%20|g'\
	<<< "$query")

[ -z "$query" ] && exit

response="$(curl -s "https://www.deezer.com/search/$query")"

case $type in
	track)formated=$(echo "$response" | sed 's|{|\n|g' | grep "SNG_ID\":" | cut -d "," -f 1,4,7 | cut -d "\"" -f 4,8,12);;
	album)formated=$(echo "$response" | sed 's|},|\n|g'| grep "{\"ALB_ID\":" | cut -d "," -f 1,2,7 | sed 's|{|\n|g' | grep "ALB_ID" | cut -d "\"" -f 4,8,12);;
	playlist)formated=$(echo "$response" | sed 's|{|\n|g'| grep "\"PLAYLIST_ID\":" | cut -d "," -f 1,4 | cut -d "\"" -f 4,8 );;
esac

choice=$(echo "$formated" | tr "\"" "-" | cut -d "-" -f 2,3 | $guicmd )
[ -z "$choice" ] && exit
id=$(echo "$formated" | tr "\"" "-" | grep -Fwm1 "$choice" | cut -d "-" -f 1)

deemix "deezer.com/en/$type/$id"
