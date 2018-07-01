#!/bin/bash
. /var/www/html/openWB/openwb.conf
	if [[ $evsecons1 == "dac" ]]; then
		sudo python /var/www/html/openWB/runs/dac.py 1557 $dacregisters1
	fi

	if [[ $evsecons1 == "modbusevse" ]]; then
		sudo python /var/www/html/openWB/runs/evsewritemodbus.py $evsesources1 $evseids1 12
	fi

echo 12 > /var/www/html/openWB/ramdisk/llsolls1
echo 1 > /var/www/html/openWB/ramdisk/ladestatuss1