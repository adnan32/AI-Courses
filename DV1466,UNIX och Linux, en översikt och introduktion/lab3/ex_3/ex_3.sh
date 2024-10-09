#!/bin/bash

# File to process
file="words.txt"

# Function to count a pattern
count_pattern() {
    local pattern=$1
    grep -io "$pattern" "$file" | wc -l
}

# Counting the patterns
ll_count=$(count_pattern "ll")
er_count=$(count_pattern "er")
up_count=$(count_pattern "up")
mm_count=$(count_pattern "mm")
ing_count=$(count_pattern "ing")
ar_count=$(count_pattern "ar")

# Adding 67
ll_count=$((ll_count + 67))
er_count=$((er_count + 67))
up_count=$((up_count + 67))
mm_count=$((mm_count + 67))
ing_count=$((ing_count + 67))
ar_count=$((ar_count + 67))

# Extracting Asc value
ll_char=$(printf "\\$(printf '%03o' "$ll_count")")
er_char=$(printf "\\$(printf '%03o' "$er_count")")
up_char=$(printf "\\$(printf '%03o' "$up_count")")
mm_char=$(printf "\\$(printf '%03o' "$mm_count")")
ing_char=$(printf "\\$(printf '%03o' "$ing_count")")
ar_char=$(printf "\\$(printf '%03o' "$ar_count")")

# Write the resutl to a file
echo "$ll_char$er_char$up_char$mm_char$ing_char$ar_char" > ascii.txt


echo "The ASCII message has been written to ascii.txt."