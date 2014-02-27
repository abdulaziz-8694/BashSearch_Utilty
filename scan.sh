#!/bin/bash

function scan
{
	#echo "Working"
	fName=$(ls "$@") #storing list of files and directories in the 	variable $fName

	while IFS=$'\n' read name #reading each filename into variable $line

	do
		if [[ $name = "" ]]; then
			break
		fi		

		echo -n -e "$@\t\t" >> index.txt #address of file

		echo -n -e "$name\t" >> index.txt #name of file

		time=$(stat --format=%y "$@""/""$name")
		
		echo -n -e "${time:0: -16}\t" >> index.txt 

		size="$(stat -c '%s' "$@""/""$name")" #size of file
		size=$((size/1024)) #converting into kilobytes

		echo -n -e "$size\t" >> index.txt

		filetype="$(file "$@""/""$name")"	#to check whether it is a directory or not
		
		if [[ ${filetype: -9} = "directory" ]]; then #checking if it is a directory or not
			echo -n -e "d\t" >> index.txt
		else
			echo -n -e "f\t" >> index.txt
		fi 

		if [[ ${name: -4} = ".txt" ]]; then  #checking if it is a text file or not
			echo "t" >> index.txt
		else
 			echo "n" >> index.txt
		fi

		if [[ ${filetype: -9} = "directory" ]]; then
			scan "$@""/""$name"
		fi
			


				

	
	done <<< "$fName"


}


d="$@" #if you want to search in other directory

if [[ $d = "" ]]; then #if no arguments passed then it takes  
	d="$(pwd)"
	#echo "working"
fi

scan "$d"
	
