#!/bin/bash
#
## ess_url: IP/URL des LG ESS V1.0
#
## ess_pass: Passwort, um sich in den LG ESS V1.0 einzuloggen
#            Das Passwort ist standardm��ig die Registrierungsnr.
#            die sich auf dem PCS (dem Hybridwechselrichter und
#            Batteriemanagementsystem) befindet (Aufkleber!). Alter-
#            nativ findet man die Registrierungsnr. in der App unter
#            dem Men�punkt "Systeminformationen"
#            Mit der Registrierungsnr. kann man sich dann in der 
#            Rolle "installer" einloggen. 
. /var/www/html/openWB/openwb.conf
ess_url="https://$lgessv1ip"
ess_pass=$lgessv1pass
#
## Pr�fen, ob ein Sessionkey in der Ramdisk vorhanden ist. Wenn nicht,
#  z.b. wenn das System neu gestartet wurde, dann wird ein Dummykey an-
#  gelegt
if test -f "/var/www/html/openWB/ramdisk/ess_session_key"; then
        session_key=$(sed -n '1p' /var/www/html/openWB/ramdisk/ess_session_key)
else
	session_key=" "
fi
#
## JSON-Objekt vom PCS abholen. Es k�nnen folgende JSON-Objekte zur�ck gegeben werden:
#   
#  1. Wenn der Sessionkey nicht korrekt bzw. wenn die Session abgelaufen ist, dann wird ein
#     JSON-Objekt mit einem Attribut "auth_key" zur�ck gegeben
#  2. Der Sessionkey ist g�ltig, dann erh�lt man ein JSON-Objekt mit den wichtigsten Attribute.
#     Beispiel JSON-Objekte liegen im Ordner lgessv1/JSON-Beispiele.txt
#
json=$(curl -s -k --connect-timeout 5 -d '{"auth_key":'$session_key'}' -H "Content-Type: application/json" -X POST $ess_url'/v1/user/essinfo/home')
authchk=$(echo $json | jq '.auth' | sed 's/.*://' | tr -d '\n' | sed 's/\"//' | sed 's/\"//')
#
## Pr�fen, ob Sessionkey ung�ltig ist, wenn ja, Login und neuen Sessionkey empfangen
#echo $authchk
#
if [ "$authchk" == "auth_key failed" ] || [ "$authchk" == "auth timeout" ] || [ "$authchk" == "" ]; then
	json=$(curl -s -k --connect-timeout 5 -d '{"password":"'$ess_pass'"}' -H "Content-Type: application/json" -X PUT $ess_url/v1/login)
	session_key=$(echo $json | jq '.auth_key' | sed 's/.*://' | tr -d '\n' | sed 's/\"//' | sed 's/\"//')
	session_key='"'$session_key'"'
	outjson='{"auth_key":'$session_key'}'
	#
	## aktuelle Daten aus dem PCS auslesen
	#
	json=$(curl -s -k --connect-timeout 5 -d $outjson -H '"Content-Type: application/json"' -X POST $ess_url/v1/user/essinfo/home)
	#
	## Sessionkey in der Ramdisk abspeichern
	#
	echo $session_key > /var/www/html/openWB/ramdisk/ess_session_key
fi
#
## JSON-Objekt auswerten
#
pcs_pv_total_power=$(echo $json | jq '.statistics.pcs_pv_total_power' | sed 's/.*://' | tr -d '\n' | sed 's/\"//' | sed 's/\"//')
#
## Daten f�r Langzeitlog holen
#
jahr=$(date +%Y)
year_of_stat='"'year'"':'"'$jahr'"'
json=$(curl -s -k --connect-timeout 5 -d '{"auth_key":'$session_key', '$year_of_stat'}' -H "Content-Type: application/json" -X POST $ess_url'/v1/user/graph/pv/year')
pvkwh=$(echo $json | jq '.loginfo[13].total_generation' | sed 's/.*://' | tr -d '\n' | sed 's/\"//' | sed 's/\"//' | sed 's/kwh//' | sed 's/\.//')
ekwh=$(echo $json | jq '.loginfo[13].total_Feed_in' | sed 's/.*://' | tr -d '\n' | sed 's/\"//' | sed 's/\"//' | sed 's/kwh//' | sed 's/\.//')
#
## Daten in Ramdisk schreiben
#
echo $pvkwh > /var/www/html/openWB/ramdisk/pvkwh
echo $ekwh > /var/www/html/openWB/ramdisk/einspeisungkwh
echo '-'$pcs_pv_total_power > /var/www/html/openWB/ramdisk/pvwatt
echo '-'$pcs_pv_total_power
