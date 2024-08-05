#!/usr/bin/env zsh


FONTFAMILY="plex-otf"
FONTSIZE="10pt"
AUTHOR="Nils Winnwa"

set -e

function printhelp
{
	echo "pdf_note markdown.md [-f || -o || -w WASSERZEICHEN || -h]"
	echo -e "\t-f | --landscape\t : Ausgabe im Querformat";
	echo -e "\t-o | --open\t\t : PDF nach Kreation öffnen";
	echo -e "\t-w | --watermark\t : Wasserzeichen in PDF einfügen";
	echo -e "\t-h | --help\t\t : Diese Hilfe";
	exit
}

function argparser
{
args=()

# Optionen mit Namen
while [ "$1" != "" ]; do
	case "$1" in
	  -f | --landscape )
						landscape="True"	;;
	  -o | --open )
						openafter="True"	;;
	  -w | --watermark )
						watermark=${2:u}	;; # Wasserzeichen festlegen und in UPPERCASE umwandeln
	  -h | --help )		
						printhelp			;; # Hilfe anzeigen
	  * )
						args+=("$1")		# Rest ist positional
	esac
	shift # Nächstes Argument
done

set -- "${args[@]}"

position_1="${args[1]}"
mdf=$position_1

# Kein MD-File angegeben
if [[ ! -f "$mdf" ]]
then
   printhelp
fi
} 

argparser "$@"

if ! type "pandoc" > /dev/null
then
	echo "Pandoc is required for conversion. Please install it or set \$PATH accordingly."
	exit 1
fi

pdfdir=$(dirname $mdf)/PDF

if [[ ! -d $pdfdir ]]
then
	echo "Erste Umwandlung in diesem Verzeichnis, erstelle PDF-Verzeichnis" 
	mkdir $pdfdir
fi


pdff=PDF/$(printf $mdf | sed 's/.md$/.pdf/')

header=$(grep "^# " $mdf | sed 's/#//; s/[[:space:]]//')


[[ ! -z "$landscape" ]] && pandoc "$mdf" -o "$pdff" -V geometry:margin=2cm -V geometry:landscape -V fontsize="$FONTSIZE" -V lang=de -V fontfamily:"$FONTFAMILY" -V title:"" --metadata title="$header" --metadata author="$AUTHOR" --pdf-engine xelatex
[[ -z "$landscape" ]] && pandoc "$mdf" -o "$pdff" -V geometry:margin=2cm -V fontsize="$FONTSIZE" -V lang=de -V fontfamily:"$FONTFAMILY" -V title:"" --metadata title="$header" --metadata author="$AUTHOR" --pdf-engine xelatex

[[ ! -z "$watermark" ]] && watermark insert -tc '#FF0000' -ts 92 -ha center -o 0.2 --unselectable "$pdff" "$watermark"


[[ ! -z "$openafter" ]] && open "$pdff" && echo "Öffne \"$pdff\"!"
[[ -z "$openafter" ]] && echo "PDF Datei \"$pdff\" geschrieben!"
