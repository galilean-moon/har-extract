# har-extract
har-extract is a simple shell script that accepts a .HAR (HTTP Archive File) as input and utilizes jq to display URL redirects and IPs from a browser interaction with a website. It also displays NS records for the website's apex domain.

***

**This program requires jq and dig to run.**

You can install jq by running the command "apt-get install jq" and dig by running the command "apt-get install dnsutils" (Debian/Ubuntu).
