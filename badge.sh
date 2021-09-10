
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

echo "Done!"