#!/usr/bin/env zsh

EDITOR=nvim
# 1. Get date mdy

mdy=$(date  +"%d-%m-%Y")

# 1.5 Check for existing notes and get latest character

curchar=$(echo $mdy-* | tr " " "\n" | sort | tail -n 1 | cut -d "-" -f 4) 2>/dev/null
if [[ "$curchar" == "" ]]
then
	nextchar="a"
elif [[ "$curchar" == "zzzzzz" ]]
then
	echo Notizlimit für heute erreicht. Mach mal nen Issue auf. Goodbye.
	exit 1
fi

# Edgecase: Noch keine Notiz vorhanden, dann "a" zurückgeben
# 2. Get next character

function get_nextchar () {
	if [[ "$nextchar" == "a" ]]
	then
		echo $nextchar
		return 0
	fi

	nextchar=$(for char in {a..z} z{a..z} zz{a..z} zzz{a..z} zzzz{a..z} zzzzz{a..z}; do echo $char; done | grep "^$curchar$" -A 1 | tail -n 1)
	echo $nextchar
	return 0
}

nextchar=$(get_nextchar)

#3. Ask User for Name
read "notename?🖋️  Name für die neue Notiz: "

notename_safe=$(echo $notename | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]') 

#4. Bringing it all together

filename="$mdy-$nextchar-$notename_safe.md"

echo "Öffne $filename mit $EDITOR"
echo "# $notename" > $filename
$EDITOR $filename
export LASTNOTE=$filename
