#! /bin/bash
if [ $# -ne 1 ]
then
	echo "usage: $0 file"
	exit 1
fi

echo "************OSS1-Project1************"

data="$1"

while true
do
	echo
	echo "[MENU]"
	echo "1. Search player stats by name in MLB data"
	echo "2. List top 5 players by SLG value"
	echo "3. Analyze the team stats - average age and total home runs"
	echo "4. Compare players in different age groups"
	echo "5. Search the players who meet specific statistical conditions"
	echo "6. Generate a performance report (formatted data)"
	echo "7. Quit"

	read -p "Enter your COMMAND (1~7):" command
	
	if [ "$command" -eq 1 ]
	then
		read -p "Enter a player name to search: " name
		echo
		echo "Player stats for \"$name\":"
		cat "$data" | awk -F, -v player="$name" '$2 == player {printf("Player: %s, Team: %s, Age: %d, WAR: %.1f, HR: %d, BA: %.3f", player, $4, $3, $6, $14, $20)}'
		echo

	elif [ "$command" -eq 2 ]
	then
		read -p "Do you want to see the top 5 players by SLG? (y/n) : " ans
		if [ "$ans" == "y" ]
		then
			echo
			echo "***Top 5 Players by SLG***"
			cat "$data" | sed '1d' | sort -t, -k22,22 -nr |  awk -F, -v i=1 '$8 >= 502 {printf("%d. %s (Team: %s) - SLG: %.3f, HR: %d, RBI: %d\n", ((i++)), $2, $4, $22, $14, $15)}' |  head -n 5
	        fi

	elif [ "$command" -eq 3 ]
	then
		read -p "Enter team abbreviation (e.g.,NYY,LAD,BOS):" team
		echo
		cat "$data" | sed '1d' |  awk -F, -v team="$team" '$4 == team {totalAge+=$3; totalHR+=$14; totalRBI+=$15; cnt++} END {if (cnt == 0) {print "non-existent team"} else {printf("Team stats for %s:\nAverage age: %.1f\nTotal home runs: %d\nTotal RBI: %d\n", team, totalAge/cnt, totalHR, totalRBI)}}'

	elif [ "$command" -eq 4 ]
	then
		echo
		echo "Compare players by age groups:"
		echo "1. Group A (Age < 25)"
		echo "2. Group B (Age 25-30)"
		echo "3. Group C (Age > 30)"
		read -p "Select age group (1-3):" n

		if [ "$n" -eq 1 ]
		then
			echo
			echo "Top 5 by SLG in Group A (Age < 25):"
			cat "$data" | sed '1d' | sort -t, -k22,22 -nr | awk -F, '$8 >= 502 && $3 < 25 {printf("%s (%s) - Age: %d, SLG: %.3f, BA: %.3f, HR: %d\n", $2, $4, $3, $22, $20, $14)}' | head -n 5
		elif [ "$n" -eq 2 ]
		then
			echo
			echo "Top 5 by SLG in Group B (Age 25-30):"
			cat "$data" | sed '1d' | sort -t, -k22,22 -nr | awk -F, '$8 >= 502 && $3 >= 25 && $3 <= 30 {printf("%s (%s) - Age: %d, SLG: %.3f, BA: %.3f, HR: %d\n", $2, $4, $3, $22, $20, $14)}' | head -n 5
		else
			echo
			echo "Top 5 by SLG in Group C (Age > 30):"
			cat "$data" | sed '1d' |  sort -t, -k22,22 -nr | awk -F, '$8 >= 502 && $3 > 30 {printf("%s (%s) - Age: %d, SLG: %.3f, BA: %.3f, HR: %d\n", $2, $4, $3, $22, $20, $14)}' | head -n 5
		fi

	elif [ "$command" -eq 5 ]
	then
		echo
		echo "Find players with specific criteria"
		read -p "Minimum home runs: " hr
		read -p "Minimum batting average (e.g., 0.280): " ba
		echo
		echo "Players with HR >= $hr and BA >= $ba :"
		cat "$data" | sed '1d' | sort -t, -k14,14 -nr | awk -F, -v hr="$hr" -v ba="$ba" '$8 >= 502 && $14 >= hr && $20 >= ba {printf("%s (%s) - HR: %d, BA: %.3f, RBI: %d, SLG: %.3f\n", $2, $4, $14, $20, $15, $22)}'

	elif [ "$command" -eq 6 ]
	then
		echo "Generate a formatted player report for which team?"
		read -p "Enter team abbreviation (e.g., NYY, LAD, BOS): " team
		echo
		echo "================= $team PLAYER REPORT ==================="
		echo "Date: $(date +%Y/%m/%d)"
		echo "------------------------------------------"
		echo "PLAYER                   HR   RBI  AVG     OBP     OPS"
		echo "------------------------------------------"
		cat "$data" | sed '1d' | sort -t, -k14,14 -nr | awk -F, -v team="$team" '$4 == team {cnt++; printf("%-25s%-5d%-5d%-8.3f%-8.3f%-8.3f\n", $2, $14, $15, $20, $21, $23)} END {printf("---------------------------------------\nTEAM TOTALS: %d players\n", cnt)}'

	elif [ "$command" -eq 7 ]
	then
		echo "Have a good day!"
		break

	fi
done

exit 0
