#!/bin/bash

echo -e "Creating folder... "

if [ ! -d "$1" ];then
mkdir $1
echo -e "\nFolder Created.."
else
echo -e "\nFolder Was Created.. "
fi
echo -e "\nSearching subdomain with Sublist3r.."
python /opt/Sublist3r/sublist3r.py -d $1 -o "$1/$1_sublist3r.txt" | sort -u

echo -e "\nSearching subdomain with amass"
amass enum -d $1 -o "$1/$1_amass.txt" | sort -u

echo -e "\nListing Live domains.."
cat "$1/$1_sublist3r.txt" | sort -u| httprobe >> "$1/$1_subdominiosvivos.txt"
cat "$1/$1_amass.txt" |sort -u | httprobe >> "$1/$1_subdominiosvivos.txt"

echo -e "\nTesting Subdomain Takeover"
#cat "$1/$1_subdominiosvivos.txt" | sort -u| sed 's/https\?:\/\///' >> "$1/$1_subdomains.txt"
cat "$1/$1_subdominiosvivos.txt" | sort -u >> "$1/$1_subdomains.txt"

python3 /opt/takeover/takeover.py -l "$1/$1_subdomains.txt" -o "$1/$1_takeover_results"
