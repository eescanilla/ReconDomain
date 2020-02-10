#!/bin/bash

echo -e "[+]Creating folder"

if [ ! -d "$1" ];then
mkdir $1
echo -e "[+] Folder Created"
else
echo -e "[+] Folder Was Created"
fi
echo -e "\n[+] Searching subdomain with Sublist3r.."
python /opt/Sublist3r/sublist3r.py -d $1 -o "$1/$1_sublist3r.txt" | sort -u
echo -e "\n[+] Done."

echo -e "\n[+] Searching subdomain with amass"
amass enum -d $1 -o "$1/$1_amass.txt" | sort -u
echo -e "\n[+] Done."

echo -e "\n[+] Listing Live domains.."
cat "$1/$1_sublist3r.txt" | sort -u| httprobe >> "$1/$1_subdominiosvivos.txt"
cat "$1/$1_amass.txt" |sort -u | httprobe >> "$1/$1_subdominiosvivos.txt"
echo -e "\n[+] Done."

echo -e "\n[+] Testing Subdomain Takeover"
cat "$1/$1_subdominiosvivos.txt" | sort -u >> "$1/$1_subdomains.txt"
python3 /opt/takeover/takeover.py -l "$1/$1_subdomains.txt" -o "$1/$1_takeover_results.txt" -v

echo -e "\n[+] Testing CORS "

while read line; do
curl='$(curl -k -s -v $line -H "Origin: https://www.google.cl" > /dev/null)'
    if [[ $curl =~ "Access-Control-Allow-Origin: https://www.google.cl" ]]; then
        echo -e $line " .... is Vulnerable to CORS"
	echo -e "curl -k -s -v $line -H "Origin: https://www.google.cl"" >> $1/$1_cors.txt
    fi
done < $1/$1_subdomains.txt

#comming... 
#echo -e "\n[+] Testing Host Header Attack"
