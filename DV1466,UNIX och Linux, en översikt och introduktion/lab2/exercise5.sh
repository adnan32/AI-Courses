#!/bin/bash
sum_of_digits() {
    number=$1
    sum=0
    while [ $number -gt 0 ]; do
        digit=$(( number % 10 ))
        sum=$(( sum + digit ))
        number=$(( number / 10 ))
    done
    echo $sum
}
rm -f numbers.txt answer.txt
count=0
while [ $count -lt 5 ]; do
    read -p "Enter an integer number greater than 0 and less than or equal to 500: " number
    if [[ $number -gt 0 && $number -le 500 ]]; then
        echo $number >> numbers.txt
        count=$(( count + 1 ))
    else
        echo "Invalid number. Please enter a number between 1 and 500."
    fi
done

while read -r number; do
    result=$(( number * 100 ))
    result=$(( result - number ))
    sum_digits=$(sum_of_digits $result)
    echo $sum_digits >> answer.txt
done < numbers.txt

echo "Numbers and their processed results have been recorded in 'numbers.txt' and 'answer.txt'."