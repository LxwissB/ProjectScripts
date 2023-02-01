#! /bin/bash


resourceaccess() {

	#Attempt to read all from /resources (last resort, very unlikely to work)

	#200 if this folder exists, 404 if not. Check before it reads contents
	if [[ $publicsite == "y" ]]
	then
		returncode=$(curl -sI https://$host/resources/ | grep "HTTP" | awk '{print $2}')
	else
		returncode=$(curl -sI $host/resources/ | grep "HTTP" | awk '{print $2}')
	fi
	if [[ $returncode != 200 ]]
	then
		echo -e "\nResource folder not present"
	else
		echo -e "\nResource folder access successful. While this script will cherrypick .js and .php files, it's worth manually verifying by visiting {host}/resources"
		echo "Note: test may not be 100% accurate. Please visit /resources to manually verify. Some hosts may use this space for a different purpose"
		curl -s -o ra.txt $host/resources/ 
		ra_js
		ra_php
	fi

}

ra_js() {

	#Grep & sed to find a mention of JS
	jsfiles=$(cat ra.txt | grep -o -P 'href.*.js(?=">)' | sed 's/href="//')
	jsfile_wc=$(echo $jsfiles | wc -w)
	#decides whether anything with the .js extension has been found
	if [[ $jsfile_wc == 0 ]]
	then
		echo -e "\nResource folder present but couldn't find a trace of JS"
	else
		echo -e "\nJS identified in the resource folder"
		echo "Below are all the discovered files in /resources that contain the .js extension"
		echo $jsfiles
		echo -e "\nNote: These are only the scripts used on the host, they may not contain any indication of vulnerability"
		found_js=true
	fi
}

ra_php() {

	#Grep & sed to find a mention of JS
	phpfiles=$(cat ra.txt | grep -o -P 'href.*.php(?=">)' | sed 's/href="//')
	phpfiles_wc=$(echo $phpfiles | wc -w)
		
	#decides whether anything with the .js extension has been found
	if [[ $phpfiles_wc == 0 ]]
	then
		echo -e "\nResource folder present but couldn't find a trace of PHP"
	else
		echo -e "\nPHP identified in the resource folder"
		echo "Below are all the discovered files in /resources that contain the .php extension"
		echo $phpfiles
		echo -e "\nNote: These are only the files used on the host, they may not contain any indication of vulnerability"
		found_php=true
	fi
}