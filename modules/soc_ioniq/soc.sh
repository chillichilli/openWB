#!/bin/bash

obd2="00:1D:A5:00:00:A5"
date=$(date)
sudo echo "$date soc.sh starting">> /var/www/html/openWB/ramdisk/soclog

	#re='^-?[0-9]+$'
	#soclevel=$(sudo python /var/www/html/openWB/modules/soc_carnet/soc.py)

	sudo bluetoothctl connect $obd2 > /dev/null
    	sudo python3 /var/www/html/openWB/modules/soc_ioniq/readobd2.py >  /dev/null
    	sudo bluetoothctl disconnect $obd2 > /dev/null

#	cat /var/www/html/openWB/ramdisk/soc >> /var/www/html/openWB/ramdisk/soclog

#	if  [[ $soclevel =~ $re ]] ; then
#		if (( $soclevel != 0 )) ; then
#			echo $soclevel > /var/www/html/openWB/ramdisk/soc
#			echo $(date +%s) > /var/www/html/openWB/ramdisk/soctime	
#		fi
#	fi

