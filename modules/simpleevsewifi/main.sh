#!/bin/bash
. /var/www/html/openWB/openwb.conf
re='^-?[0-9]+$'
rekwh='^[-+]?[0-9]+\.?[0-9]*$'

altervs=$(</var/www/html/openWB/ramdisk/vehiclestate)

output=$(curl --connect-timeout $evsewifitimeoutlp1 -s http://$evsewifiiplp1/getParameters)
vehiclestate=$(echo $output | jq '.list[] | .vehicleState')
evsestate=$(echo $output | jq '.list[] | .evseState')
if [[ $evsestate -eq 'false' ]]; then
#	output2=$(curl --connect-timeout $evsewifitimeoutlp1 -s "http://$evsewifiiplp1/setStatus?active=true")
	output=$(curl --connect-timeout $evsewifitimeoutlp1 -s http://$evsewifiiplp1/getParameters)
#	vehiclestate=1	
fi

#echo  $output

watt=$(echo $output | jq '.list[] | .actualPower')
lla1=$(echo $output | jq '.list[] | .currentP1')
lla2=$(echo $output | jq '.list[] | .currentP2')
lla3=$(echo $output | jq '.list[] | .currentP3')
#llaktuell=$(echo $output | jq '.list[] | .actualCurrent')
watt=$((llaktuell*230))
#llkwh=$(echo $output | jq '.list[] | .meterReading')
#watt=$(echo "scale=0;$watt * 1000 /1" |bc)


#echo $vehiclestate
if [[ $vehiclestate =~ $re ]] ; then
	echo $vehiclestate > /var/www/html/openWB/ramdisk/vehiclestate

	# Auto gerade angeschlossen -> neuen soc ermitteln
	if (( altervs < 2 )); then
		if (( vehiclestate > 1 )); then
			echo "1" > /var/www/html/openWB/ramdisk/soc
			echo $(date +%s) > /var/www/html/openWB/ramdisk/soctime	
		fi
	fi

	# falls Auto getrennt wird, direkt soc auf 0
	if (( altervs > 1 )); then
		if (( vehiclestate < 2 )); then
			echo "0" > /var/www/html/openWB/ramdisk/soc
			echo $(date +%s) > /var/www/html/openWB/ramdisk/soctime
		fi
	fi
# von s.sh
  if [[ $vehiclestate -gt 1 ]]; then
	  sudo echo "1" > /var/www/html/openWB/ramdisk/plugstat
  else
	  sudo echo "0" > /var/www/html/openWB/ramdisk/plugstat
  fi

  if [[ $vehiclestate -gt 2 ]]; then
	sudo echo "1" > /var/www/html/openWB/ramdisk/chargestat

	if [[ $lla1 =~ $re ]] ; then
		echo $lla1 > /var/www/html/openWB/ramdisk/lla1
	fi
	if [[ $lla2 =~ $re ]] ; then
		echo $lla2 > /var/www/html/openWB/ramdisk/lla2
	fi
	if [[ $lla3 =~ $re ]] ; then
		echo $lla3 > /var/www/html/openWB/ramdisk/lla3
	fi

  else
	sudo echo "0" > /var/www/html/openWB/ramdisk/chargestat
	watt=0
	lla1=0
	echo "0" > /var/www/html/openWB/ramdisk/llaktuell
    	echo "0" > /var/www/html/openWB/ramdisk/lla1
  fi

fi

