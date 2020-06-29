#!/bin/bash 

VERSION="1.0"

echo -e "WARNUNG: Dieses Skript ersetzt ALLE Vorkommen von \"localhost\", \"8080\" und \"8081\" in der ausgewaehlten Datei."
echo -e "Dabei wird noch NICHT kontextsensitiv zwischen Server und Client Adresse unterschieden."
echo -e "Skript Version: $VERSION \n" 



echo -e "Geben Sie die Datei an, welche bearbeitet werden soll \nWenn sie nichts angeben, wird standardmaessig \"realm-export.json\" verwendet:" 
read FILE

echo -e "Geben Sie die IP-Adresse an unter welcher die cBioPortal Instanz erreichbar ist \nFormat Beispiel: \"192.168.178.1\" (ohne Anfuehrungszeichen) \nWenn sie nichts angeben, wird standardmaessig \"localhost\" verwendet:" 
read NEW_IP

echo -e "\nGeben Sie den Port an unter welchem die cBioPortal Instanz für HTTP Verbindungen erreichbar ist \nFormat Beispiel: \"80\" (ohne Anfuehrungszeichen) \nWenn sie nichts angeben, wird standardmaessig \"8080\" verwendet:"
read NEW_STD_PORT

echo -e "\nGeben Sie den Port an unter welchem die cBioPortal Instanz für HTTPS/SSL Verbindungen erreichbar ist \nFormat Beispiel: \"443\" (ohne Anfuehrungszeichen) \nWenn sie nichts angeben, wird standardmaessig \"8081\" verwendet:"
read NEW_SSL_PORT



if [ "$FILE" == "" ]
then
	FILE="realm-export.json"
fi

if [ "$NEW_IP" == "" ]
then
	NEW_IP="localhost"
fi

if [ "$NEW_STD_PORT" = "" ]
then
	NEW_STD_PORT="8080" 
fi

if [ "$NEW_SSL_PORT" = "" ]
then
	NEW_SSL_PORT="8081"
fi



echo -e "\nSollen wirklich folgende Werte in die Datei \"$FILE\" uebernommen werden? IP: $NEW_IP, HTTP-Port: $NEW_STD_PORT, SSL-Port: $NEW_SSL_PORT \n(\"J\" zum Uebernehmen, \"N\" zum Abbrechen)"
read doit



if [[ "$doit" == [jJ] ]]
then
	COUNT_IP=$(grep -o "localhost" $FILE | wc -l)
	sed -i "s/localhost/$NEW_IP/g" $FILE

	COUNT_STD=$(grep -o ":8080" $FILE | wc -l)
	sed -i "s/:8080/:$NEW_STD_PORT/g" $FILE

	COUNT_SSL=$(grep -o ":8081" $FILE | wc -l)
	sed -i "s/:8081/:$NEW_SSL_PORT/g" $FILE

	COUNT_SUM=$(($COUNT_IP + $COUNT_STD + $COUNT_SSL))

	echo -e "\nInsgesamt wurden $COUNT_SUM Aenderungen an der Datei \"$FILE\" vorgenommen \nIP: $COUNT_IP \nHTTP-Port: $COUNT_STD \nSSL-Port: $COUNT_SSL" 
	echo -e "\nSkript ist fertig"

	exit 0;
fi



echo -e "\nSkript wurde abgebrochen - keine Aenderungen wurden an der Datei \"$FILE\" vorgenommen" 

exit 1;
