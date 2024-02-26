#!/bin/bash
#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#------------------------------
		#Variables
#------------------------------
declare -i parameterCount=0
API_KEY="********************************"
#------------------------------
#		URL
#------------------------------
function ctrl_c (){
	echo -e "${yellowColour}\n[!]${endColour} ${greenColour}Ended process${endColour}\n"
}
trap ctrl_c INT

function helpPanel(){
	echo -e "\n[+] Help Panel\n"
	echo -e "	-c : Curasao, CO"
	echo -e "	-l : La Valette, FR"
	echo -e "	-m : My Location"
	echo -e "	-n : New Zealand, NZ"
	echo -e "	-p : Príncipe, ST\n"
}

function weather(){
	main_url="https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$API_KEY"
	echo "$(curl -s $main_url)" > report.txt
	cat report.txt | js-beautify | sponge report.txt

	#Equivalent extraction of information JSON
	#description=$(cat report.txt | jq -j '.weather[0].description')
	#temperatura=$(cat report.txt | jq -r '.main.temp')
	#sensacion_termica=$(cat report.txt | jq -r '.main.feels_like')
	#temp_min=$(cat report.txt | jq -r '.main.temp_min')
    	#temp_max=$(cat report.txt | jq -r '.main.temp_max')
	
	date=$(cat report.txt | grep "dt" | awk 'NF{print $NF}' | tr -d ',' | xargs -I{} date -d @{})
	description_e=$(cat report.txt | grep "description" | awk -F: '{print $2}' | tr -d '":,')
	visibility=$(cat report.txt | grep "visibility" | awk 'NF{print $NF}' | tr -d ',')
	temperature_e=$(cat report.txt | grep -E "feels_like|temp_min|temp_max" | tr -d '",'|sed 's/$/ °C/' | sed 's/^ *//')
	speed_wind=$(cat report.txt | grep -E "speed" |sed 's/$/ "m\/s"/' | tr -d '",' | sed 's/:/ -->/' | sed 's/^ *//')
	deg_wind=$(cat report.txt | grep -E "deg" |sed 's/$/°/' | tr -d '",' | sed 's/:/ -->/'| sed 's/^ *//')
	speedAndWind=$(echo "$speed_wind from $deg_wind")
	location_country=$(cat report.txt | grep -E "country" | awk -F: '{print $2}' | tr -d ',"' | sed 's/^ *//')
	location_state=$(cat report.txt | grep -E "name" | awk -F: '{print $2}' | tr -d ',"' | sed 's/^ *//')
	sunrise=$(cat report.txt | grep -E "sunrise|sunset" | awk '{print $NF}' | tr -d ',' | xargs -I {} date -d @{} | awk 'NR==1{print}')
	sunset=$(cat report.txt | grep -E "sunrise|sunset" | awk '{print $NF}' | tr -d ',' | xargs -I {} date -d @{} | awk 'NR==2{print}')

	echo -e "\nDate: $date"
	echo -e "Location: $location_state, $location_country"
	echo -e "\nForecast: $description_e"
	echo -e "Visibility: $(awk "BEGIN {printf \"%.1f\", $visibility / 1000}") km"
	echo -e "$temperature_e"
	echo -e "Wind: $speedAndWind"
	echo -e "Sunrise: $sunrise"
	echo -e "Sunset: $sunset"
	echo " "


}
#------------------------------------------pROGRAM FLOW-------------------------------------------------

while getopts "hnclp" arg; do
	case $arg in
		c)let parameterCount+=2;;
		l)let parameterCount+=3;;
		n)let parameterCount+=1;;
		p)let parameterCount+=4;;
		h);;
	esac
done

if [ $parameterCount -eq 1 ];  then
	lat="-41.5000831"
	lon="172.8344077"
	weather
elif [ $parameterCount -eq 2 ]; then
	lat="6.1270218"
	lon="-70.6269756"
	weather
elif [ $parameterCount -eq 3 ];then
	lat="44.9413712"
	lon="5.8548466"
	weather
elif [ $parameterCount -eq 4 ];then
	lat="1.6103558"
	lon="7.3992579"
	weather
else
	helpPanel
fi

