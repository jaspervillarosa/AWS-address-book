#!/bin/bash

# Created by: Jasper Villarosa
# Date Created: April 15, 2024
# Latest Update: April 16, 2024
# This script is an AWS Address Book management tool that allows users to register, delete, update, search for, list all, and exit member records stored in a CSV file, providing a menu-driven interface for user interaction.

# display the menu of the AWS-address-book
display_menu(){
	clear
	echo "************ WELCOME TO AWS Address Book *****************"
	echo "----------------------------------------------------------"
	echo "---------------  Address Book Menu  ----------------------"
	echo "=========================================================="
	echo " 1. Register a member"
	echo " 2. Delete a member"
	echo " 3. Update the member"
	echo " 4. Search a member"
	echo " 5. List all"
	echo " 6. Exit "
	echo "=========================================================="
	
	echo -n "Enter your choice: "
}

# function that call the menu 1. Register a member
register_member(){

	if [ ! -f "AWS-address-book.csv" ];then
		echo "=========================================================="
		echo "---------  Creating AWS address book csv file  -----------"
		echo "=========================================================="
		# Adding a header for the csv file
		echo "User (Last, First),Dev,Location,Email" >> AWS-address-book.csv
	fi

	while true; do
    	echo "Enter member details (last, first): "
		echo -n "Name: "
		read name
		if [[ "${name}" == *", "* ]]; then
			# Check if the member already exists
			if grep -q "${name}" AWS-address-book.csv; then
				echo -n "Member already exists. Do you want to update the existing record? (Y/N): "
				read update_choice
				case $update_choice in
					[Yy]*) update_member "${name}" 
						exit ;;
					*) return;;
				esac
				break
			else
				echo "Enter your assigned Dev: "
				echo -n "Dev: "
				read dev
				echo "Enter your location (Makati, Alabang, Cebu): "
				echo -n "Location: "
				read location

				email_regex="^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$"
				while true; do
					echo "Enter your awsys email: "
					echo -n "Awsys Email: "
					read email
					if [[ $email =~ $email_regex ]]; then
							break
					else
						clear
						echo "----------------------------------------------------------"
						echo "--- Invalid email format. Please enter a valid address ---"
						echo "----------------------------------------------------------"
					fi
				done

				if [ -z "$name" ] || [ -z "$dev" ] || [ -z "$location" ] || [ -z "$email" ]; then
					echo "----------------------------------------------------------------------------"
					echo "All fields are required. Please complete the information asked and try again"
					echo "----------------------------------------------------------------------------"
				else
					break #Break the loop if all fields are provided
				fi
			fi #mark
		else
			echo "----------------------------------------------------------"
			echo "--- Enter the correct name in (Last, First) format"
			echo "----------------------------------------------------------"
		fi
	
		
	done

	# For clean name format in CSV

	# Separate first name and last name
	first_name=$(echo "$name" | cut -d ',' -f2 | sed 's/^ *//')
	last_name=$(echo "$name" | cut -d ',' -f1 | sed 's/^ *//')

	# Format the name to "Last, First"
	formatted_lastName=$(echo "$last_name" | tr '[:upper:]' '[:lower:]' | sed 's/.*/\u&/') 
	formatted_firstName=$(echo "$first_name" | tr '[:upper:]' '[:lower:]' | sed 's/.*/\u&/') 

	# Replace space with comma
	formatted_name=$(echo "$formatted_lastName", "$formatted_firstName"| sed 's/ / /')

	# Add a member to the text file

	echo "${formatted_name}, $dev,$location,$email " >> AWS-address-book.csv

	echo "----------------------------------------------------------"
	echo "Member ${formatted_name} registered successfully"
	echo "----------------------------------------------------------"
}
# function that call the menu 2. Delete a member
delete_member(){

	while true; do
    echo -n "Enter the name of the member you want to delete: "
    read delete_name
    if [[ "$delete_name" == *", "* ]]; then
        if grep -qFw "$delete_name" AWS-address-book.csv; then
            break
        else
            echo "----------------------------------------------------------"
            echo "------- Member not found. Enter an existing name. --------"
            echo "----------------------------------------------------------"
        fi
    else
        echo "----------------------------------------------------------"
        echo "--- Enter the correct name in (Last, First) format"
        echo "----------------------------------------------------------"
    fi
	done

	sed -i "/$delete_name/d" AWS-address-book.csv
	echo "----------------------------------------------------------"
	echo "The member $delete_name was deleted successfully"
	echo "----------------------------------------------------------"

}

# function that call the menu 3. Update the member
update_member(){
	
	while true; do
    echo -n "Enter the name of the member to be updated (last, first): "
	read update_name

    if [[ "$update_name" == *", "* ]]; then
        if grep -q -e "$update_name" AWS-address-book.csv; then
			echo "----------------------------------------------------------"
			echo "------------  Member found. Current details  -------------"
			echo "----------------------------------------------------------"
			grep "$update_name" AWS-address-book.csv
            break
        else
            echo "----------------------------------------------------------"
            echo "------- Member not found. Enter an existing name. --------"
            echo "----------------------------------------------------------"
        fi
    else
        echo "----------------------------------------------------------"
        echo "--- Enter the correct name in (Last, First) format"
        echo "----------------------------------------------------------"
    fi
	done

	echo "=========================================================="
	echo "-- Choose which part of the member's details to update  --"
	echo "=========================================================="

	echo "1. Name"
	echo "2. Dev"
	echo "3. Location"
	echo "4. Email"
	echo "5. Cancel"
	echo -n "Enter your choice: "
	read choice

	case $choice in
		  1) 
            echo -n "Enter the new name (last, first): "
            read new_name
			sed -i -E "s/^($update_name)/${new_name}/" AWS-address-book.csv
            echo "Name updated successfully"
            ;;
        2) 
            echo -n "Enter the new Dev: "
            read new_dev
            sed -i -E "s/^($update_name),[^,]*,(.*)$/\1,$new_dev,\2/" AWS-address-book.csv
            echo "Dev updated successfully";;
        3) 
            echo -n "Enter the new location: "
            read new_location
            sed -i -E "s/^($update_name)([^,]*,[^,]*,)[^,]*/\1\2$new_location/" AWS-address-book.csv
            echo "Location updated successfully";;
        4)  
            echo -n "Enter the new Email: "
            read new_email
            sed -i -E "s/^($update_name)([^,]*,[^,]*,[^,]*,)(.*)$/\1\2$new_email/" AWS-address-book.csv
            echo "Email updated successfully";;
		5) 
			echo "Update canceled."
			sleep 2;
			display_menu;;
		*) 
			echo "Invalid choice. Update cancelled";;
	esac
}
# function that call the menu 4. Search a member
search_member(){
	echo -n "Enter the name of the member you want to search for: "
	read search_name

	# Search for the member in the csv file
	search_result=$(grep -i "$search_name" AWS-address-book.csv)

	# Check if the result is empty
	if [ -z "$search_result" ]; then
		echo "No member found with the name '$search_name'"
	else
		echo "Below is the searched member"
		echo "========================================================" 
		echo "User | Dev | Location | Awsys Email " 
	    echo "--------------------------------------------------------" 
		echo "$search_result"
		echo "========================================================" 
	fi
}	
# function that call the menu 5. List all
list_all(){
	echo "Below are the registed AWS members"

	echo "AWS Address Book" 
	echo "==========================================================" 
	echo "User | Dev | Location | Awsys Email " 
	echo "----------------------------------------------------------" 
	cat AWS-address-book.csv
	echo "==========================================================" 

}
# function that call the menu 6. Exit
exit_(){
	clear
	echo "Exiting ..."
	sleep 2
	echo "The application was terminated successfully!"
}

# Main loop
while true
do
	display_menu
	read choice

	case $choice in
		1) 
		   register_member
		   echo "Press enter to continue..."
		   read -r
		   clear
		;;
		2) 
		   delete_member
		   echo "Press enter to continue..."
		   read -r
		   clear
		;;
		3) 
		   update_member
		   echo "Press enter to continue..."
		   read -r
		   clear
		;;
		4) 
		   search_member
		   echo "Press enter to continue..."
		   read -r
		   clear
		;;
		5) 
		   list_all
		   echo "Press enter to continue..."
		   read -r
		   clear
		;;
		6) 
		   exit_
		   break
		;;
		*) 
		   echo "Invalid choice. Please try again."
		   sleep 2
		;;
	esac
done

