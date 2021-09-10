#!/bin/bash

help() {
	echo ""
	echo "Usage: $0 -k key -v value"
	echo "\t-k The value to be displayed on the left side of the badge"
	echo "\t-v The value to be displayed on the right side of the badge"
	exit 1
}

while getopts "k:v:" opt; do
	case "$opt" in
	k) key="$OPTARG" ;;
	v) value="$OPTARG" ;;
	?) help ;;
	esac
done

if [ -z "$key" ] || [ -z "$value" ]; then
	echo "You are missing one of the require params."
	help
fi

WIDTH_PER_LETTER="4.566"
CONTAINER_RATIO="0.531"
TEXT_FACTOR="100"
MARGIN="10"

function calculateContainer() {
	local text=$1
	local amountOfLetters=${#text}

	local width=$(awk -v letters="${amountOfLetters}" -v font_size="${WIDTH_PER_LETTER}" -v padding="${MARGIN}" 'BEGIN{result=(letters * font_size + (padding * 2)); print result;}')
	
	echo $width
}

function calculateTextSize() {
	local text=$1
	local amountOfLetters=${#text}

	local size=$(awk -v letters="${amountOfLetters}" -v font_size="${WIDTH_PER_LETTER}" -v padding="${MARGIN}" 'BEGIN{result=(letters * font_size + (padding * 2)); print result;}')
	
	echo $size
}

function generate() {
	local key=$1
	local value=$2
	
	local leftContainerSize="$(calculateContainer $key)"
	local rightContainerSize="$(calculateContainer $value)"
	local totalSize=$(awk -v left="${leftContainerSize}" -v right="${rightContainerSize}" 'BEGIN{result=(left + right); print result;}')

	local leftX="261.5"
	local leftLength="403.0"

	local rightX="715.5"
	local rightLength="345.0"

	echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
			<svg xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" width=\"${totalSize}\" height=\"20\">
				<linearGradient id=\"smooth\" x2=\"0\" y2=\"100%\">
					<stop offset=\"0\" stop-color=\"#bbb\" stop-opacity=\".1\" />
					<stop offset=\"1\" stop-opacity=\".1\" />
				</linearGradient>
				<clipPath id=\"round\">
					<rect width=\"${totalSize}\" height=\"20\" rx=\"3\" fill=\"#fff\" />
				</clipPath>
				<g clip-path=\"url(#round)\">
					<rect width=\"${leftContainerSize}\" height=\"20\" fill=\"#555\" />
					<rect x=\"${leftContainerSize}\" width=\"${rightContainerSize}\" height=\"20\" fill=\"#007ec6\" />
					<rect width=\"${totalSize}\" height=\"20\" fill=\"url(#smooth)\" />
				</g>
				<g fill=\"#fff\" text-anchor=\"middle\" font-family=\"DejaVu Sans,Verdana,Geneva,sans-serif\" font-size=\"110\">
					<text x=\"${leftX}\" y=\"150\" fill=\"#010101\" fill-opacity=\"0.3\" transform=\"scale(0.1)\" textLength=\"${leftLength}\" lengthAdjust=\"spacing\">${key}</text>
					<text x=\"${leftX}\" y=\"140\" transform=\"scale(0.1)\" textLength=\"403.0\" lengthAdjust=\"spacing\">${key}</text>
					<text x=\"${rightX}\" y=\"150\" fill=\"#010101\" fill-opacity=\"0.3\" transform=\"scale(0.1)\" textLength=\"${rightLength}\" lengthAdjust=\"spacing\">${value}</text>
					<text x=\"${rightX}\" y=\"140\" transform=\"scale(0.1)\" textLength=\"345.0\" lengthAdjust=\"spacing\">${value}</text>
				</g>
			</svg>"
}

function save() {
   local badge=$1

   echo $badge > badge.svg
}

save "$(generate $key $value)"

echo "Done!"