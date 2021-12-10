#!/bin/bash
. hyrule_castle_fonc.sh
. hyrule_castle_bgc.sh

--title_screen

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

play=0 #0 pour jouer, 1 pour escape
non=0 #pour skip le tour de l'ennemi si le choix de l'escape est non (relancer le tour du joueur)

if [[ $want_play = 1 ]]; then
    --difficulty_selection
    --fight_nb_selection
    . hyrule_castle_var.sh
    echo -e "\n \nYou enter the Tower of $boss. You will have to fight his soldiers to reach the summit and defeat him. Good luck, $player."
    for boss_loop in `seq 1 $fight_nb`; do
	floor_nb=1
	while [[ $(($floor_nb)) -le 10 && $play = 0 ]]; do


	    if [[ $player_hp -gt 0 ]]; then
		#Adaptation for boss fight
		echo $floor_nb
		if [[ $floor_nb = 10 ]]; then
		    enemy_max_hp=$boss_max_hp
		    enemy_hp=$boss_hp
		    enemy_str=$boss_str
		    enemy=$boss
		    echo -e "\n\n\n======================================================= WELCOME TO THE FINAL FLO\
OR ======================================================="
		    echo -e "You finally arrived in front of $boss. Well done!"
		    echo "Try to survive."
		else
		    enemy_max_hp=$enm_max_hp
		    enemy_hp=$enm_max_hp
		    enemy_str=$enm_str
		    enemy=$enm
		    echo -e "\n\n\n======================================================= WELCOME TO THE FLOOR $((10 * ($boss_loop - 1) + $floor_nb)) / $(($fight_nb*10)) ======================================================="
		    echo "A wild $enemy appears."
		fi
		
		#Launch enemy fight
		while [[ $player_hp -gt 0 && $enemy_hp -gt 0 && $play = 0  ]]; do

		    echo -e "\n============================== FIGHT $((10 * ($boss_loop - 1) + $floor_nb)) ==============================="

		    echo -e "\n${RED}$enemy${NC}"
		    --hp_display $enemy_hp $enemy_max_hp

		    echo -e "\n${GREEN}$player${NC}"
		    --hp_display $player_hp $player_max_hp

		    #Player turn
		    echo -e "\nWhat do you want to do?"
		    echo "1- Attack | 2- Heal | 3- Protect | 4- Escape"
		    act=0
		    non=0
		    p=0 #var test si je protect
		    while [[ $act != 1 ]]; do
			read -s -n 1 action
			if [[ $action = "1" ]]; then
			    enemy_hp=$(--attack $player_str $enemy_hp)
			    echo -e "\nYour attack dealt $player_str damages."
			    act=1
			elif [[ $action = "2" && $player_hp != $player_max_hp ]]; then
			    player_hp=$(--heal $player_hp $player_max_hp)
			    echo -e "\nYou used heal."
			    act=1
			elif [[ $action = "2" && $player_hp = $player_max_hp ]]; then
			    echo "Oh sweet summer child, your heatlh is already full. Don't be cringe."
			    echo "1- Attack | 3- Protect | 4- Escape"
			elif [[ $action = "3" ]]; then #protect
			    p=1
			    echo -e "\nNext damages will be reduced."
			    act=1
			elif [[ $action = "4" ]]; then #escap
			    wrong_input=0
			    while [[ $wrong_input = 0 ]]; do
				echo -e "\nDo you want quit the game? (y/n?)"
				read -s -n 1 answer
				if [[ "$answer" != "${answer#[Yy]}" ]]; then
				    echo -e "Bye $player!"
				    act=1
				    play=1
				    wrong_input=1
				elif [[ "$answer" != "${answer#[Nn]}" ]]; then
				    non=1
				    wrong_input=1
				    act=1
				    break;
				fi
			    done
			else
			    echo "Wrong input. Are you dumb ?"
			    echo "1- Attack | 2- Heal | 3- Protect | 4- Escape"
			fi


		    done

		    #Enemy turn
		    if [[ $enemy_hp -gt 0 && $play = 0 && $non = 0 ]]; then
			if [[ $p = "1" ]]; then
			    player_hp=$(--get_dmg $(($enemy_str/2)) $player_hp)     #dmgs/2 pour la protec
			    echo -e "\n$enemy attacked and dealt $(($enemy_str/2)) damages."
			else
			    player_hp=$(--get_dmg $enemy_str $player_hp)
			    echo -e "\n$enemy attacked and dealt $enemy_str damages."
			fi
			sleep 2
		    fi
		done


		#Fight is over

		if [[ $player_hp -le 0 ]]; then
		    echo "You died. Next time, chose your actions better."
		fi
		if [[ $enemy_hp -le 0 ]]; then
		    if [[ $((10 * ($boss_loop - 1) + $floor_nb)) = 1 ]]; then
			echo -e "Congratulations, you defeated $enemy! You won $((10 * ($boss_loop - 1) + $floor_nb)) coin."
		    else
			echo -e "Congratulations, you defeated $enemy! You won $((10 * ($boss_loop - 1) + $floor_nb)) coins."
		    fi
		    coin=$(($coin+$((10 * ($boss_loop - 1) + $floor_nb))))
		    echo "You now have $coin coins"
		    if [[ $((10 * ($boss_loop - 1) + $floor_nb)) != $(($fight_nb * 10 )) ]]; then
			echo "Navi will teleport you to the next floor."
			read -s -p "Press enter when you are ready."
		    fi
		fi
		
	    fi
	    floor_nb=$(($floor_nb+1))
	done
	if [[ $player_hp -gt 0 && $play = 0 ]]; then
	    echo -e "\nYou finally saved Zelda, she is forever in love with you."
	fi
    done
else
    echo -e "\nBye bye"
fi



