#!/bin/bash

# Usage ./autoSeeker-2.sh 9ine
# Where 9ine is the folder name of target in /result
target=$1

# required arguments
if [ "$#" -ne 1 ]; then
  echo -e "Script requires 1 argument:
  • subdomains list | eg. hackerone
  • Usage: ./sto.sh hackerone"
  exit 1
fi

function subdomain_takeover(){
	echo -e "\n\n[$(date "+%H:%M:%S")] CHECKING FOR SUBDOMAIN TAKEOVER USING SUBZY"
	if [ ! -d "$target-sto" ]; then
		mkdir -p $target-sto;
	fi
	subzy run --targets $target --vuln --hide_fails | sed 1,7d | anew -q $target-sto/subdomain_takeover.txt;

	if [ -s "$target-sto/subdomain_takeover.txt" ]; then
	    var=$(cat $target-sto/subdomain_takeover.txt | wc -l);
	    echo -e "[$(date "+%H:%M:%S")] $var possible domains vulnerable to subdomain takeover";
	    echo -e "[$(date "+%H:%M:%S")] File saved as '$target-sto/subdomain_takeover.txt'";
	    #python3 notification.py "$(echo -e "[ $(date "+%H:%M:%S") ] [ *$target* ] [ 2-autoSeeker ]\n\n$var possible domains vulnerable to subdomain takeover\n\nFile saved as > $target/subdomain_takeover.txt")"

	    #CNAME records checking to preciously extract potential domains for STO
	    function cname_checker(){
			if [ -s "$target-sto/subdomain_takeover.txt" ]; then
				echo -e "\n\n[$(date "+%H:%M:%S")] CHECKING CNAME RECORDS TO EXTRACT POTENTIAL DOMAINS"	
				grep -Eo '([a-zA-Z0-9.-]+)\.[a-zA-Z]{2,}' "$target-sto/subdomain_takeover.txt" | anew -q "$target-sto/check_cname.txt"

				# Function to check records
			    python3 ./cname_checker.py $target-sto/check_cname.txt | anew -q $target-sto/subdomain_takeover_cname.txt;

			    # Checking if anything found
				cname_file="$target-sto/subdomain_takeover_cname.txt"
				if [ -s "$cname_file" ]; then
				    all=$(wc -l < "$target-sto/subdomain_takeover.txt")
				    cname=$(grep -c "\[CNAME-DOMAIN\]" "$cname_file")

				    if (( cname >= 1 )); then
				        echo -e "[$(date "+%H:%M:%S")] $cname/$all have CNAME records"
				        echo -e "[$(date "+%H:%M:%S")] Verify error & CNAME point to get close to STO, saved as > $target-sto/subdomain_takeover_cname.txt"
				    	echo -e "[$(date "+%H:%M:%S")] For more info: https://github.com/EdOverflow/can-i-take-over-xyz";
				    else
				        echo -e "[$(date "+%H:%M:%S")] No CNAME records found for STO vulnerable domains, means they're false positive!"
				    	echo -e "[$(date "+%H:%M:%S")] For more info: https://github.com/EdOverflow/can-i-take-over-xyz";
				    fi
				fi
				rm -f $target-sto/check_cname.txt;
			fi
		}
		cname_checker

	else
	    echo -e "[$(date "+%H:%M:%S")] No vulnerable subdomain found"
	    rm $target-sto/subdomain_takeover.txt;
	fi
	echo -e "-------------------------------------------------";
}
subdomain_takeover
