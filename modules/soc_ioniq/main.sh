#!/bin/bash

. /var/www/html/openWB/openwb.conf
touch /var/www/html/openWB/ramdisk/soctimer
vwtimer=$(</var/www/html/openWB/ramdisk/soctimer)
#vwtimer=6
#if (( vwtimer < 60 )); then
if (( vwtimer < 6 )); then
	vwtimer=$((vwtimer+1))
	echo $vwtimer > /var/www/html/openWB/ramdisk/soctimer
else
	vehiclestate=$(</var/www/html/openWB/ramdisk/vehiclestate)
	if (( vehiclestate > 2)); then
                cd /var/www/html/openWB/modules/soc_ioniq
		bash /var/www/html/openWB/modules/soc_ioniq/soc.sh &
		#Abfrage Ladung aktiv. Setzen des soctimers. 
	
		if (( ladeleistung > 800 )) ; then
			vwtimer=$((60 * (10 - $soccarnetintervall) / 10))
			echo $vwtimer > /var/www/html/openWB/ramdisk/soctimer
		else
			echo 1 > /var/www/html/openWB/ramdisk/soctimer
		fi
		#echo 1 > /var/www/html/openWB/ramdisk/soctimer
	fi
fi
