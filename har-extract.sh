#!/bin/bash

if [[ "$#" -eq 0 || ! -f "$1" ]]; then
	printf "\nUsage: %s [FILE]\n" "$(basename "$0")"
	printf "=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~==~=~=~=~=~=~=~="
	printf "\nThis program accepts a .har (HTTP Archive file) as input, and outputs extracted IPs and redirects.\n\n"
	exit 1
fi

FILE=$1
MATCH=""
declare -A SEEN_APEX

if command -v jq >/dev/null 2>&1 && command -v dig >/dev/null 2>&1; then
	printf "\n~=~=~=~ Extracting redirects and URL for domains(): ~=~=~=~\n"
	jq -r '.log.pages[] | select (.title) | .title' "$FILE"

	printf "\n~=~=~=~ Redirects, IPs, and NS hostnames: ~=~=~=~\n"	
	MATCH=$(jq -r '.log.entries[] | select (.response.redirectURL != "") | .response.redirectURL' "$FILE" | sed 's/https*:\/\///g; s/\/.*//g' | sort -u)
	while IFS= read -r line; do
		[[ -z "$line" ]] && continue
		if [[ $line == "www."* ]]; then
			printf "%s\n%s\n" "$line" "${line#www.}"
			SEEN_APEX["${line#www.}"]=1
		else
			printf "%s\nwww.%s\n" "$line" "$line"
			SEEN_APEX["$line"]=1
		fi
	done <<< "$MATCH"
	jq -r '.log.entries[] | select (.serverIPAddress  != null) | .serverIPAddress' "$FILE" | sort -u
	for apex in "${!SEEN_APEX[@]}"; do dig "$apex" NS +short | sed 's/\.$//' | sort; done
	exit 0
else
	printf "\njq and/or dig is not installed. This program requires both to run.\n\nTo install, run the command 'sudo apt-get install jq dnsutils'\n\n"
	exit 1
fi
