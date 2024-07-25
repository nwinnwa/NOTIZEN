#!/usr/bin/env zsh


FONTFAMILY="plex-otf"
FONTSIZE="10pt"
mdf=$1

if [[ -z "$mdf" ]]
then
	echo "First argument must be the MD-File you want to convert"
	exit 1
fi
if [[ ! -f "$mdf" ]]
then
	echo "First argument must be the MD-File you want to convert. \"$mdf\" is not a file."
	exit 1
fi
if ! type "pandoc" > /dev/null
then
	echo "Pandoc is required for conversion. Please install it or set \$PATH accordingly."
	exit 1
fi

if [[ "$2" == "-o" ]]
then
	openafter="True"
fi

if [[ "$3" == "-o" ]]
then
	openafter="True"
fi

if [[ "$2" == "-f" ]]
then
	landscape="True"
fi

if [[ "$3" == "-f" ]]
then
	landscape="True"
fi

watermark_private="True"

pdfdir=$(dirname $mdf)/PDF

if [[ ! -d $pdfdir ]]
then
	echo "Erste Umwandlung in diesem Verzeichnis, erstelle PDF-Verzeichnis" 
	mkdir $pdfdir
fi


pdff=PDF/$(printf $mdf | sed 's/.md$/.pdf/')

header=$(grep "^# " $mdf | sed 's/#//; s/[[:space:]]//')


[[ ! -z "$landscape" ]] && pandoc "$mdf" -o "$pdff" -V geometry:margin=2cm -V geometry:landscape -V fontsize="$FONTSIZE" -V lang=de -V fontfamily:"$FONTFAMILY" -V title:"" --metadata title="$header" --metadata author="Nils Winnwa" --pdf-engine xelatex
[[ -z "$landscape" ]] && pandoc "$mdf" -o "$pdff" -V geometry:margin=2cm -V fontsize="$FONTSIZE" -V lang=de -V fontfamily:"$FONTFAMILY" -V title:"" --metadata title="$header" --metadata author="Nils Winnwa" --pdf-engine xelatex

[[ ! -z "$watermark_private" ]] && watermark insert -tc '#FF0000' -ts 92 -ha center "$pdff" "VERTRAULICH"


[[ ! -z "$openafter" ]] && open "$pdff" && echo "Öffne \"$pdff\"!"
[[ -z "$openafter" ]] && echo "PDF Datei \"$pdff\" geschrieben!"
