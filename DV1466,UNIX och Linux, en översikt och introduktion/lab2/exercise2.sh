#!/bin/bash
roll_die() {
    local sides=$1
    echo $(( RANDOM % sides + 1 ))
}

roll_dice() {
    local die=$1
    local num_dice=$2
    local sides

    case $die in
        d4) sides=4 ;;
        d6) sides=6 ;;
        d8) sides=8 ;;
        d10) sides=10 ;;
        d12) sides=12 ;;
        d20) sides=20 ;;
        *) return ;;
    esac

    echo "Rolling $num_dice for the dice type $die"
    for (( i = 1; i <= num_dice; i++ )); do
        result=$(roll_die $sides)
        echo "Roll $i: $result"
    done
}

while true; do
    echo "Please choose the type of die to roll (d4, d6, d8, d10, d12, d20) or 'q' to quit:"
    read -p "Enter die type: " die_type

    if [[ "$die_type" == "q" ]]; then
        echo "Exiting. Goodbye!"
        break

    elif [[ "$die_type" =~ ^d(4|6|8|10|12|20)$ ]]; then
        read -p "Enter the number of dice to roll: " num_dice


        roll_dice "$die_type" "$num_dice"
    else
        echo "Invalid die type"
    fi
	echo 
done
