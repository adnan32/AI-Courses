#!/bin/bash
while true; do
	echo "welcome to your manipulation tool"
	echo "choice one alternative to perform"
	echo "l. List the files in the current directory"
	echo "c. Change to specific directory and list the content"
	echo "n. Create a new file"
	echo "r. Rename a specific file"
	echo "d. Delete a specific file"
	echo "q. Quit"
	read -p "Enter your choice: " input
	if [[ "$input" == "q" ]]; then
		echo "Quitting the script"
		break
	elif [[ "$input" == "l" ]]; then
		echo "The files in this directory:"
		ls
	elif [[ "$input" == "c" ]]; then
    	read -p "Enter the path to the directory you want to list the content of (absolute path recommended): " path
    	absolute_path=$(realpath "$path")
    	if [[ -d "$absolute_path" ]]; then
        	cd "$absolute_path"
        	echo "Contents of $absolute_path:"
        	ls
    	else
        	echo "The directory \"$absolute_path\" does not exist. Please try again."
    	fi
	elif [[ "$input" == "n" ]]; then
		read -p "Enter the name of the file: " name
		touch "$name"
		echo "The file $name is creaed successfully"
	elif [[ "$input" == "r" ]]; then
		read -p "Enter the file name that you want to change: " bname
		if [[ -f "$bname" ]]; then
			read -p "Enter the new file name: " nname
			mv "$bname" "$nname"
			echo "the file name $bname has been renamed to $nname"
		else
			echo "the name does not exist in this directory"
		fi
	elif [[ "$input" == "d" ]]; then
		read -p "Enter the name of the file you want to delete: " dname
		if [[ -f "$dname" ]]; then
			read -p "Are you sure you want to delete $dname (yes:y/no:n)): " sure
			if [[ "$sure" == "y" ]]; then
				rm "$dname"
				echo "The file has been deleted successfully"
			fi
		else
			echo "The file $dname does not exist in this directory"
		fi
	else
		echo "Invalid choice. Please try again."

	fi
		echo
done
