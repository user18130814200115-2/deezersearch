#!/bin/sh

[ "$1" == "-h" ] && echo -e "deezersearch.sh [TYPE] [QUERY]\n[TYPE] is one of three: track, album, artist\n[QUERY] is the search term" && exit

guicmd='fzf --no-info --height=6'

[ -z $1 ] && type=$(echo -e "track\nalbum\nplaylist" | $guicmd ) || type="$1"
[ -z $type ] && exit

[ -z "$2" ] && echo -n "Search: " && read query || query="$2"

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
