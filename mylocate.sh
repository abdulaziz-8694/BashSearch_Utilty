#!/bin/bash

function checkDir {
	filelist="$1"
	echo "$filelist" | grep $'\t'"d"$'\t' #only those line having d
}

function checkText {
	filelist="$1"
	echo "$filelist" | grep "t$" #only those lines having t
}

function checkSize {
	filelist="$1"
	givensize="$2"
	while IFS=$'\n' read -r line
	do
		size="$(echo "$line" | grep -o $'\t'[0-9]*$'\t')" #extracting the size from each line
		if [[ "$size" -ge "$givensize" ]]; then
			echo "$line"
		fi
	done <<< "$filelist"
}

function checkDate {
	filelist="$1"
	giventime="$2"
	value="$(echo "$giventime" | awk -F':' '{print $3"-"$2"-"$1" "$4":"$5":00"}')" #converting the given time into the format as stored in index.txt
	gt=$(date --date="$value" +%s) #converting into epoch time
	while IFS=$'\n' read -r line
	do
		listed_date="$(echo "$line" | awk -F'\t' '{print $3}')"
		lt="$(date --date="$listed_date" +%s)"
		#echo "$lt"
		if [[ "$lt" > "$gt" ]]; then
			echo "$line"
		fi
	done <<< "$filelist"
	
}

#function checkName {
##	filelist="$1"
#	name="$2"
#	filelist
#s}

if [[ ! -f "index.txt" ]]; then #if index.txt is not found
	echo "index.txt not found. Generating index.txt"
	if [[ ! -f "scan.sh" ]]
		echo "scan.sh not found . Exiting...."
		exit
	fi
	./scan.sh #generates index.txt
fi

if [[ "$1" = "" ]]
	echo "no filenames to search. Exiting"
	exit
fi

arg_checked=1

list=$(cat index.txt)

#echo "$list"
for i in "$@"
do
	if [[ $arg_checked -gt "$#" ]]; then #if all the arguments are checked 
		break 
	fi
	
	if [[ $arg_checked -eq "1" ]]; then
		list="$(cat index.txt | grep $'\t'"$1")"
		#echo "$list"
	else
		arg="${@:$((arg_checked)):1}" #for each arguments it will check the following cases 
		case $arg in
			"-dir")
			d=1
			list="$(checkDir "$list")"
			#echo "$list"
			#echo "$d"
			;;

			"-date")
			let "arg_checked+=1"
			givendate="${@:$((arg_checked)):1}"
			list="$(checkDate "$list" "$givendate")"
			#echo "$list"
			#echo "$givendate"
			;;

			"-size")
			let "arg_checked+=1"
			size="${@:$((arg_checked)):1}"
			list="$(checkSize "$list" "$size")"
			#echo "$list"
			#echo "$size"
			;;

			"-t")
			t=1
			list="$(checkText "$list")"
			#echo "$list"
			#echo "$t"
			;;	
		esac
		

	fi	
	

	let "arg_checked+=1"
done
while IFS=$'\n' read -r line
do
	path=$(echo "$line" | awk -F'\t' '{print $1}')
	echo "$path"

done <<< "$list"

