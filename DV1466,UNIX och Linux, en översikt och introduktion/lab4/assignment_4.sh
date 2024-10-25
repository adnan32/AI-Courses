#!/bin/bash

declare -A warrior
declare -A black_lord

roll_dice() {
    local notation=$1
    local num_dice=${notation%%d*}
    local die_sides=${notation##*d}

    local sum=0
    for ((i=0; i<num_dice; i++)); do
        roll=$(( RANDOM % die_sides + 1 ))
        sum=$(( sum + roll ))
    done
    echo $sum
}

initialize_characters() {
    warrior=(
        [HP]=95
        [STR]=5
        [DEX]=0
        [CON]=2
        [WIS]=3
        [INT]=0
        [FOR]=14
        [REF]=12
        [WIL]=15
        [ATK]=18
        [DC]=24
        [BASE_DC]=24
        [DC_bonus]=0
        [guard_up_active]=0
        [healing_potion_used]=0
        [vanishing_potion_used]=0
        [vanishing_potion_rounds]=0
        [barkskin_potion_used]=0
        [barkskin_potion_rounds]=0
    )

    black_lord=(
        [HP]=80
        [STR]=0
        [DEX]=4
        [CON]=0
        [WIS]=2
        [INT]=2
        [FOR]=8
        [REF]=14
        [WIL]=14
        [ATK]=17
        [DC]=24
    )
}

initiative_roll() {
    echo "*** Roll for initiative! ***"
    echo ""
    read -p "* Press enter to roll initiative *"

    warrior_roll=$(roll_dice "1d20")
    warrior_initiative=$(( warrior[DEX] + warrior_roll ))
    echo "The warrior DEX bonus is ${warrior[DEX]} and roll ${warrior_roll}, total initiative is $warrior_initiative."
    sleep 2
    black_lord_roll=$(roll_dice "1d20")
    black_lord_initiative=$(( black_lord[DEX] + black_lord_roll ))
    echo "The Black Lord DEX bonus is ${black_lord[DEX]}, total initiative is $black_lord_initiative."
    echo ""

    if (( warrior_initiative >= black_lord_initiative )); then
        echo "The warrior goes first!"
        sleep 1
        first_turn="warrior"
    else
        echo "The Black Lord goes first!"
        sleep 1
        first_turn="black_lord"
    fi
    echo ""
}

warrior_attack_with_sword() {
    echo "The warrior attacks the Black Lord with the Emerald Sword!"
    read -p "* Press enter to roll dice for the warrior attack *"
    attack_roll=$(roll_dice "1d20")
    total_attack=$(( warrior[ATK] + attack_roll ))
    if (( total_attack > black_lord[DC] )); then
        echo "The warrior rolls a $total_attack, and Black lord DC ${black_lord[DC]} the attack hits the Black Lord!"
        read -p "* Press enter to roll for damage! *"
        damage_roll=$(roll_dice "1d8")
        damage=$(( warrior[STR] + damage_roll ))
        black_lord[HP]=$(( black_lord[HP] - damage ))
        sleep 3
        echo "The warrior deals $damage points of damage to the Black Lord!"
        sleep 3
    else
        sleep 3
        echo "But with only a $attack_roll on the dice, total attack of $total_attack, and Black lord DC ${black_lord[DC]} the Black Lord dodges the attack!"
        sleep 3
    fi
}

black_lord_spectral_claws() {
    echo "The Black Lord attacks using his spectral claws!"
    attack_roll=$(roll_dice "1d20")
    total_attack=$(( black_lord[ATK] + attack_roll ))
    sleep 3
    if (( total_attack > warrior[DC] )); then
        echo "The Warrior DC is ${warrior[DC]} And the attack hits the warrior!"
        sleep 3
        damage_roll=$(roll_dice "2d8")
        damage=$(( black_lord[DEX] + damage_roll ))
        # Appling barkskin effect
        if [[ ${warrior[barkskin_potion_used]} -eq 1 && ${warrior[barkskin_potion_rounds]} -eq 2 ]]; then
            damage=$(( damage - 2 ))
            if (( damage < 0 )); then damage=0; fi
            sleep 1
            echo "The barkskin potion reduces the damage by 2."
            sleep 1
        fi
        warrior[HP]=$(( warrior[HP] - damage ))
        echo "The Black Lord deals $damage points of damage to the warrior. The warrior has ${warrior[HP]} HP left!"
        sleep 3
    else
        echo "But the warrior parries the attack!"
        sleep 3
    fi
}

warrior_guard_up() {
    sleep 3
    echo "The warrior raises the Emerald Sword and takes a defensive stance."
    warrior[DC]=$(( warrior[DC] + 2 ))
    sleep 3
    echo "The warrior's DC is increased to ${warrior[DC]} until the beginning of your next turn."
    sleep 3
    warrior[guard_up_active]=1
}

reset_warrior_dc() {
    if [[ ${warrior[guard_up_active]} == 1 ]]; then
        warrior[DC]=${warrior[BASE_DC]}
        warrior[guard_up_active]=0
        sleep 3
        echo "The effect of guard-up has worn off. The warrior's DC returns to ${warrior[DC]}."
        sleep 3
    fi
}

warrior_drink_healing_potion() {
    sleep 1
    echo "The warrior drinks a healing potion."
    sleep 1
    healing_amount=$(roll_dice "1d8")
    warrior[HP]=$(( warrior[HP] + healing_amount ))
    echo "The warrior heals $healing_amount HP and now has ${warrior[HP]} HP."
    sleep 1
    warrior[healing_potion_used]=1
}

warrior_drink_vanishing_potion() {
    sleep 1
    echo "The warrior drinks a vanishing potion."
    sleep 1
    warrior[DC_bonus]=$(( warrior[DC_bonus] + 2 ))
    warrior[DC]=$(( warrior[BASE_DC] + warrior[DC_bonus] ))
    echo "The warrior's DC is increased to ${warrior[DC]} for the next 3 rounds."
    sleep 1
    warrior[vanishing_potion_used]=1
}

warrior_drink_barkskin_potion() {
    sleep 1
    echo "The warrior drinks a barkskin potion."
    sleep 1
    echo "The warrior will subtract 2 points from every damage received for the next 2 rounds."
    sleep 1
    warrior[barkskin_potion_used]=1
}

warrior_turn() {
    echo ""
    read -p "* Press enter to continue *"
    echo ""
    echo "It is the warrior's turn."
    actions_performed=0
    max_actions=2
    while (( actions_performed < max_actions )); do
        echo "The warrior can:"
        sleep 1
        echo "- attack with sword (1)"
        sleep 1
        echo "- guard-up (2)"
        sleep 1
        if [[ ${warrior[healing_potion_used]} -eq 0 ]]; then
            sleep 1
            echo "- drink healing potion (3)"
        fi
        if [[ ${warrior[vanishing_potion_used]} -eq 0 ]]; then
            sleep 1
            echo "- drink vanishing potion (4)"
        fi
        if [[ ${warrior[barkskin_potion_used]} -eq 0 ]]; then
            sleep 1
            echo "- drink barkskin potion (5)"
        fi
        echo ""
        sleep 2
        attempts=0
        while true; do
            read -p "* What will the warrior do? *: " action
            if [[ "$action" == 1 ]]; then
                echo ""
                warrior_attack_with_sword
                actions_performed=$(( actions_performed + 1 ))
                break
            elif [[ "$action" == 2 ]]; then
                echo ""
                warrior_guard_up
                actions_performed=$max_actions
                break
            elif [[ "$action" == 3 && ${warrior[healing_potion_used]} -eq 0 ]]; then
                echo ""
                warrior_drink_healing_potion
                actions_performed=$(( actions_performed + 1 ))
                break
            elif [[ "$action" == 4 && ${warrior[vanishing_potion_used]} -eq 0 ]]; then
                echo ""
                warrior_drink_vanishing_potion
                actions_performed=$(( actions_performed + 1 ))
                break
            elif [[ "$action" == 5 && ${warrior[barkskin_potion_used]} -eq 0 ]]; then
                echo ""
                warrior_drink_barkskin_potion
                actions_performed=$(( actions_performed + 1 ))
                break
            else
                attempts=$((attempts + 1))
                if (( attempts >= 2 )); then
                    echo "Invalid action. You lost this action."
                    break
                else
                    echo "Invalid action. Please try again."
                fi
            fi
        done
        if (( actions_performed < max_actions )); then
            echo ""
            read -p "* Press enter to continue to your next action *"
            echo ""
        fi
    done
}

vanishing_potion_effect() {
    if [[ ${warrior[vanishing_potion_used]} -eq 1 ]]; then
        if [[ ${warrior[vanishing_potion_rounds]} -lt 3 ]]; then
            (( warrior[vanishing_potion_rounds]++ ))
            sleep 1
            echo "Vanishing potion round: ${warrior[vanishing_potion_rounds]}"
            sleep 1
        fi
        if [[ ${warrior[vanishing_potion_rounds]} -eq 3 ]]; then
            warrior[DC_bonus]=$(( warrior[DC_bonus] - 2 ))
            warrior[DC]=$(( warrior[BASE_DC] + warrior[DC_bonus] ))
            sleep 1
            echo "The effect of the vanishing potion has worn off. The warrior's DC returns to ${warrior[DC]}."
            sleep 1
        fi
    fi
}

barksin_potion_effect() {
    if [[ ${warrior[barkskin_potion_used]} -eq 1 ]]; then
        if [[ ${warrior[barkskin_potion_rounds]} -lt 2 ]]; then
            (( warrior[barkskin_potion_rounds]++ ))
            sleep 1
            echo "Barksin potion round: ${warrior[barkskin_potion_rounds]}"
            sleep 1
        fi
        if [[ ${warrior[barkskin_potion_rounds]} -eq 2 ]]; then
            sleep 1
            echo "The effect of the Barksin potion has worn off."
            sleep 1
        fi
    fi
}

black_lord_drain_life() {
    echo "The Black Lord attempts to drain life from the warrior!"
    read -p "* Press enter to roll for the warrior's Fortitude save *"
    for_roll=$(roll_dice "1d20")
    total_for=$(( warrior[FOR] + for_roll ))
    echo "The warrior's FOR bonus is ${warrior[FOR]}, and rolled ${for_roll}, total is $total_for."
    sleep 3
    if (( total_for < 23 )); then
        echo "The result is lower than 23. The Black Lord's drain life succeeds!"
        sleep 3
        damage_roll=$(roll_dice "1d4")
        damage=$(( damage_roll ))
        warrior[HP]=$(( warrior[HP] - damage ))
        black_lord[HP]=$(( black_lord[HP] + 5 ))
        echo "The Black Lord deals $damage points of damage to the warrior and heals 5 HP."
        sleep 3
        echo "The warrior has ${warrior[HP]} HP left."
        sleep 3
    else
        sleep 3
        echo "The warrior resists the drain life attack!"
        sleep 3
    fi
}

black_lord_turn() {
    actions_performed=0
    max_actions=2

    echo ""
    read -p "* Press enter to continue *"
    echo ""
    echo "It is the Black Lord's turn."

    while (( actions_performed < max_actions )); do
        sleep 3
        echo "The Black Lord is selecting an action..."
        action_choice=$(( RANDOM % 2 ))
        sleep 3
        if (( action_choice == 0 )); then
            black_lord_spectral_claws
            sleep 3
        else
            black_lord_drain_life
            sleep 3
        fi
        actions_performed=$(( actions_performed + 1 ))
        if (( actions_performed < max_actions && warrior[HP] > 0 )); then
            echo ""
            read -p "* Press enter for the Black Lord's next action *"
            echo ""
        fi
    done
}

check_victory() {
    if (( warrior[HP] <= 0 )); then
        game_over="yes"
        echo ""
        echo "*** EPILOGUE ***"
        echo "The warrior has fallen in battle. The Black Lord's darkness engulfs Tanglebriar."
        echo "You have been defeated by the Black Lord."
        echo ""
        echo "*** GAME OVER ***"
    elif (( black_lord[HP] <= 0 )); then
        game_over="yes"
        echo ""
        echo "*** EPILOGUE ***"
        echo "After the furious battle, the Black Lord, mortally wounded, collapses in front of the warrior!"
        echo "You defeated the Black Lord and saved Tanglebriar!"
        echo "However, your celebration is short. As the new custodian of the sword, you must leave the kingdom and return to the vault."
        echo "It is there where you will sleep, holding the Emerald Sword, until its power is required once more."
        echo "Little did you know that when that moment comes, you would have transformed into a green dragon by the magic of the sword."
        echo ""
        echo "*** CONGRATULATIONS, YOU WIN! ***"
    fi
}

main_game() {
    initialize_characters
    echo "----------------------------------------------------"
    echo "-          THE EMERALD SWORD Part II               -"
    echo "----------------------------------------------------"
    echo ""
    round_number=1
    while (( warrior[HP] > 0 && black_lord[HP] > 0 )); do
        echo ""
        echo "*** The fight begins, ROUND $round_number ***"
        vanishing_potion_effect
        barksin_potion_effect
        echo ""
        sleep 1
        initiative_roll
        if [[ $first_turn == "warrior" ]]; then
            reset_warrior_dc
            warrior_turn
            check_victory
            [[ $game_over == "yes" ]] && break 
            black_lord_turn
            check_victory
            [[ $game_over == "yes" ]] && break  
        else
            black_lord_turn
            check_victory
            [[ $game_over == "yes" ]] && break
            reset_warrior_dc
            warrior_turn
            check_victory
            [[ $game_over == "yes" ]] && break
        fi
        round_number=$(( round_number + 1 ))
    done
}

main_game