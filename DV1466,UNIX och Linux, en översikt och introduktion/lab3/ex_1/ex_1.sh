#!/bin/bash

# Function to generate random letters with spaces in between
generate_content() {
    local lines=$1
    local letters_per_line=$2
    local file_name=$3

    # Create the file and generate the content
    > "$file_name"
    for (( i=0; i<lines; i++ )); do
        line=""
        for (( j=0; j<letters_per_line; j++ )); do
            letter=$(tr -dc 'a-zA-Z' < /dev/urandom | head -c 1)
            line="$line$letter "
        done
        echo "$line" >> "$file_name"
    done
}

# Create the files with appropriate number of lines and letters per line

# Leg files: 70 lines, 20 letters per line
generate_content 70 20 "right leg inscription.txt"
generate_content 70 20 "left leg inscription.txt"

# Arm files: 40 lines, 15 letters per line
generate_content 40 15 "right arm inscription.txt"
generate_content 40 15 "left arm inscription.txt"

# Chest file: 15 lines, 40 letters per line
generate_content 15 40 "chest inscription.txt"

# Back file: 35 lines, 40 letters per line
generate_content 35 40 "back inscription.txt"

echo "Inscription files created successfully."