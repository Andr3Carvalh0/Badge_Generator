#!/bin/bash
#
# Created by André Carvalho in September 2021
# Last modifies: 10th September 2021
#
# A very optimistic & naive implementation of https://github.com/google/pybadges in a shell script.
#

MIN_CHAR_SIZE="57.5"
MIN_FONT_SIZE="0.48"
MARGIN="10"
FONT_SCALE="100"

function help() {
	echo ""
	echo "Usage: $0 -k key -v value"
	echo "\t-k, --key\t The value to be displayed on the left side of the badge"
	echo "\t-v, --value\t The value to be displayed on the right side of the badge"
	echo "\t-c, --color\t The hex value for the value side background"
	echo "\t-o, --output\t The name of the output file"
	exit 1
}

while [ $# -gt 0 ]; do
	case "$1" in
		-k|-key|--key) key="$2" ;;
		-v|-value|--value) value="$2" ;;
		-c|-color|--color) color="$2" ;;
		-o|-output|--output) filename="$2" ;;
	esac
	shift
	shift
done

if [ -z "$key" ] || [ -z "$value" ]; then
	echo "You are missing one of the require params."
	help
fi

if [ -z "$color" ]; then
	color="#007ec6"
else
	if [[ $color != \#* ]]; then
		color="#$color"
	fi
fi

if [ -z "$filename" ]; then
	filename="output.svg"
fi

function calculateWidth() {
	local text=$1
	local amountOfLetters=${#text}
	local normalizedSize=$(awk -v size="${amountOfLetters}" -v min="${MIN_CHAR_SIZE}" 'BEGIN{result=(min + ((size / 5) * 4)); print result;}')

	local width=$(awk -v size="${amountOfLetters}" -v font_size="${normalizedSize}" -v margin="${MARGIN}" 'BEGIN{result=(((size * font_size) / margin) + margin); print result;}')
	
	echo $width
}

function calculateTextSize() {
	local text=$1
	local amountOfLetters=${#text}
	local normalizedSize=$(awk -v size="${amountOfLetters}" -v min="${MIN_FONT_SIZE}" 'BEGIN{result=(min + (size / 100)); print result;}')

	local size=$(awk -v size="${amountOfLetters}" -v font_size="${FONT_SIZE}" -v scale="${FONT_SCALE}" -v margin="${MARGIN}" 'BEGIN{result=(size * font_size * (scale + margin)); print result;}')
	
	echo $size
}

function generate() {
	local key=$1
	local value=$2
	
	local leftWidth="$(calculateWidth $key)"
	local leftX=$(awk -v left="${leftWidth}" 'BEGIN{result=(((left / 2) + 1) * 10); print result;}')
	local leftLength=$(calculateTextSize $key)

	local rightWidth="$(calculateWidth $value)"
	local rightX=$(awk -v left="${leftWidth}" -v right="${rightWidth}" 'BEGIN{result=(((left + (right / 2)) - 1) * 10); print result;}')
	local rightLength=$(calculateTextSize $value)

	local totalWidth=$(awk -v left="${leftWidth}" -v right="${rightWidth}" 'BEGIN{result=(left + right); print result;}')

	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
			<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"${totalWidth}\" height=\"20\">
				<linearGradient id=\"smooth\" x2=\"0\" y2=\"100%\">
					<stop offset=\"0\" stop-color=\"#bbb\" stop-opacity=\".1\" />
					<stop offset=\"1\" stop-opacity=\".1\" />
				</linearGradient>
				<clipPath id=\"round\">
					<rect width=\"${totalWidth}\" height=\"20\" rx=\"3\" fill=\"#fff\" />
				</clipPath>
				<g clip-path=\"url(#round)\">
					<rect width=\"${leftWidth}\" height=\"20\" fill=\"#555\" />
					<rect x=\"${leftWidth}\" width=\"${rightWidth}\" height=\"20\" fill=\"$color\" />
					<rect width=\"${totalWidth}\" height=\"20\" fill=\"url(#smooth)\" />
				</g>
				<g fill=\"#fff\" text-anchor=\"middle\" font-family=\"DejaVu Sans,Verdana,Geneva,sans-serif\" font-size=\"110\">
					<text x=\"${leftX}\" y=\"150\" fill=\"#010101\" fill-opacity=\"0.3\" transform=\"scale(0.1)\" textLength=\"${leftLength}\" lengthAdjust=\"spacing\">${key}</text>
					<text x=\"${leftX}\" y=\"140\" transform=\"scale(0.1)\" textLength=\"${leftLength}\" lengthAdjust=\"spacing\">${key}</text>
					<text x=\"${rightX}\" y=\"150\" fill=\"#010101\" fill-opacity=\"0.3\" transform=\"scale(0.1)\" textLength=\"${rightLength}\" lengthAdjust=\"spacing\">${value}</text>
					<text x=\"${rightX}\" y=\"140\" transform=\"scale(0.1)\" textLength=\"${rightLength}\" lengthAdjust=\"spacing\">${value}</text>
				</g>
			</svg>"
}

function save() {
   local badge=$1
   local filename=$2

   echo $badge > $filename
}

save "$(generate $key $value)" $filename