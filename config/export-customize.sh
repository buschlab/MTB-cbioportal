#!/bin/bash 

VERSION="1.2"

echo -e "WARNUNG: Dieses Skript ersetzt ALLE Vorkommen von \"localhost\" und \"8080\" in der ausgewaehlten Datei."
echo -e "Dabei wird noch NICHT kontextsensitiv zwischen Server und Client Adresse unterschieden, daher kann das Skript nur auf die noch unveraenderte Beispiel-Datei angewendet werden."
echo -e "Skript Version: $VERSION \n" 



echo -e "Geben Sie die Datei an, welche bearbeitet werden soll \nWenn sie nichts angeben, wird standardmaessig \"realm-export.json\" verwendet:" 
read FILE

echo -e "\nGeben Sie die IP-Adresse an unter welcher die cBioPortal Instanz erreichbar ist \nFormat Beispiel: \"192.168.178.1\" (ohne Anfuehrungszeichen) \nWenn sie nichts angeben, wird standardmaessig \"localhost\" verwendet:" 
read NEW_IP

echo -e "\nGeben Sie den Port an unter welchem die cBioPortal Instanz für Verbindungen erreichbar ist \nFormat Beispiel: \"80\" (ohne Anfuehrungszeichen) \nWenn sie nichts angeben, wird standardmaessig \"8080\" verwendet:"
read NEW_PORT

echo -e "\nIst der eben angegebene Port nur per HTTP oder auch per HTTPS/SSL erreichbar? \n(\"J\" fuer nur HTTP, \"N\" fuer HTTPS/SSL) \nWenn sie nichts angeben, wird standardmaessig HTTPS/SSL verwendet:"
read HTTP


if [ "$FILE" == "" ]
then
	FILE="realm-export.json"
fi

if [ "$NEW_IP" == "" ]
then
	NEW_IP="localhost"
fi

if [ "$NEW_PORT" = "" ]
then
	NEW_PORT="8080" 
fi

if [ "$HTTP" = "" ]
then
	HTTP="N" 
fi



echo -e "\nSollen wirklich folgende Werte in die Datei \"$FILE\" uebernommen werden? IP: $NEW_IP, Port: $NEW_PORT \n(\"J\" zum Uebernehmen, \"N\" zum Abbrechen)"
read doit





if [[ "$doit" == [jJ] ]]
then

	if [[ "$HTTP" == [jJ] ]]
	then
		sed -i "s/https/http/g" $FILE
	fi

	COUNT_IP=$(grep -o "localhost" $FILE | wc -l)
	sed -i "s/localhost/$NEW_IP/g" $FILE

	COUNT_PORT=$(grep -o ":8080" $FILE | wc -l)
	sed -i "s/:8080/:$NEW_PORT/g" $FILE

	COUNT_SUM=$(($COUNT_IP + $COUNT_PORT))

	echo -e "\nInsgesamt wurden $COUNT_SUM Aenderungen an der Datei \"$FILE\" vorgenommen \nIP: $COUNT_IP \nPort: $COUNT_PORT" 
	echo -e "\nSkript ist fertig"

	exit 0;
fi



echo -e "\nSkript wurde abgebrochen - keine Aenderungen wurden an der Datei \"$FILE\" vorgenommen" 

exit 1;
