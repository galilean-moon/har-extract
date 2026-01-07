#!/bin/bash

if [[ "$#" -eq 0 || ! -f "$1" ]]; then
	printf "\nUsage: %s [FILE]\n" "$(basename "$0")"
	printf "=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~==~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~="
	printf "\nThis program accepts a .har (HTTP Archive file) as input, and outputs extracted IPs and redirects.\n"
	exit 1
fi

FILE=$1
MATCH=""

if command -v jq >/dev/null 2>&1; then
	printf "\n~=~=~=~ Extracting redirects and URL for domains(): =~=~=~\n"
	jq -r '.log.pages[] | select (.title) | .title' "$FILE"

	printf "\n~=~=~=~ Redirects and IPs: =~=~=~\n"	
	MATCH=$(jq -r '.log.entries[] | select (.response.redirectURL != "") | .response.redirectURL' "$FILE" | sed 's/https*:\/\///g; s/\/.*//g' | sort -u)
	for line in $MATCH; do
		if [[ $line == "www."* ]]; then
			echo "$line" | tee >(sed 's/www.//g')
		else
			printf "%s\nwww.%s\n" "$line" "$line"
		fi
	done
	jq -r '.log.entries[] | select (.serverIPAddress  != null) | .serverIPAddress' "$FILE" | sort -u
	exit 0
else
	printf"\njq is not installed. This program requires jq to run.\nTo install jq, run the command "pt-get install jq.""
	exit 1
fi
