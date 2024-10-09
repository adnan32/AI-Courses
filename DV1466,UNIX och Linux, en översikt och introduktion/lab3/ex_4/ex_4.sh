#!/bin/bash

input_file="rings.txt"
output_file="rearranged_rings.txt"

# Read the input file line by line
while IFS= read -r line; do
    # Extract words
    words=($line)

    # Identify the word
    ing_word=""
    ed_word=""
    es_word=""

    for word in "${words[@]}"; do
        if [[ $word == *ing ]]; then
            ing_word=$word
        elif [[ $word == *ed ]]; then
            ed_word=$word
        elif [[ $word == *es ]]; then
            es_word=$word
        fi
    done

    
    echo "$ing_word $ed_word $es_word" >> "$output_file"

done < "$input_file"

echo "Rearranged content written to $output_file"