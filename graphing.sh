#!/bin/bash
graphing(){
#Ladestatuslog keurzen
echo "$(tail -100 /var/www/html/openWB/ramdisk/ladestatus.log)" > /var/www/html/openWB/ramdisk/ladestatus.log
#Live Graphing
pvgraph=$((pvwatt * -1))
if (( speichervorhanden == 1 )); then
	echo $speicherleistung >> /var/www/html/openWB/ramdisk/speicher-live.graph
	echo $speichersoc >> /var/www/html/openWB/ramdisk/speichersoc-live.graph
fi
if [[ socmodul1 != "none" ]]; then
	echo $soc1 >> /var/www/html/openWB/ramdisk/soc1-live.graph
fi
echo $ladeleistunglp1 >> /var/www/html/openWB/ramdisk/ev1-live.graph
if (( lastmanagement == 1 )); then
	echo $ladeleistunglp2 >> /var/www/html/openWB/ramdisk/ev2-live.graph
fi
echo $pvgraph >> /var/www/html/openWB/ramdisk/pv-live.graph
echo $wattbezugint >> /var/www/html/openWB/ramdisk/evu-live.graph
echo $ladeleistung >> /var/www/html/openWB/ramdisk/ev-live.graph
echo $soc >> /var/www/html/openWB/ramdisk/soc-live.graph
date +%H:%M >> /var/www/html/openWB/ramdisk/time-live.graph
echo $hausverbrauch >> /var/www/html/openWB/ramdisk/hausverbrauch-live.graph
if (( verbraucher1_aktiv == 1 )); then
	echo $verbraucher1_watt >> /var/www/html/openWB/ramdisk/verbraucher1-live.graph
	echo $(( verbraucher1_watt + pvgraph/3 )) >> /var/www/html/openWB/ramdisk/haus1-live.graph
fi
if (( verbraucher2_aktiv == 1 )); then
	echo $verbraucher2_watt >> /var/www/html/openWB/ramdisk/verbraucher2-live.graph
	echo $(( verbraucher2_watt + pvgraph/3 )) >> /var/www/html/openWB/ramdisk/haus2-live.graph
fi
if (( verbraucher3_aktiv == 1 )); then
	echo $verbraucher3_watt >> /var/www/html/openWB/ramdisk/verbraucher3-live.graph
	echo $(( verbraucher3_watt + pvgraph/3 )) >> /var/www/html/openWB/ramdisk/haus3-live.graph
fi


if [[ $livegraph =~ $re ]] ; then      
	livegraph=$((livegraph * 6 ))
	if ! [[ $livegraph =~ $re ]] ; then
		livegraph="30"
	fi
fi
echo $(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$verbraucher3_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8 >> /var/www/html/openWB/ramdisk/all-live.graph
echo $(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$verbraucher3_watt > /var/www/html/openWB/ramdisk/all-live.graph?incremental=y
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/all-live.graph)" > /var/www/html/openWB/ramdisk/all-live.graph
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/hausverbrauch-live.graph)" > /var/www/html/openWB/ramdisk/hausverbrauch-live.graph
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/pv-live.graph)" > /var/www/html/openWB/ramdisk/pv-live.graph
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/soc-live.graph)" > /var/www/html/openWB/ramdisk/soc-live.graph
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/evu-live.graph)" > /var/www/html/openWB/ramdisk/evu-live.graph
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/ev-live.graph)" > /var/www/html/openWB/ramdisk/ev-live.graph 
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/ev1-live.graph)" > /var/www/html/openWB/ramdisk/ev1-live.graph 
if (( verbraucher1_aktiv == 1 )); then
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/verbraucher1-live.graph)" > /var/www/html/openWB/ramdisk/verbraucher1-live.graph 
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/haus1-live.graph)" > /var/www/html/openWB/ramdisk/haus1-live.graph 
fi
if (( verbraucher2_aktiv == 1 )); then
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/verbraucher2-live.graph)" > /var/www/html/openWB/ramdisk/verbraucher2-live.graph 
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/haus2-live.graph)" > /var/www/html/openWB/ramdisk/haus2-live.graph 
fi
if (( verbraucher3_aktiv == 1 )); then
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/verbraucher3-live.graph)" > /var/www/html/openWB/ramdisk/verbraucher3-live.graph 
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/haus3-live.graph)" > /var/www/html/openWB/ramdisk/haus3-live.graph 
fi
if (( lastmanagement == 1 )); then
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/ev2-live.graph)" > /var/www/html/openWB/ramdisk/ev2-live.graph 
fi
echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/time-live.graph)" > /var/www/html/openWB/ramdisk/time-live.graph
if ((speichervorhanden == 1 )); then
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/speicher-live.graph)" > /var/www/html/openWB/ramdisk/speicher-live.graph
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/speichersoc-live.graph)" > /var/www/html/openWB/ramdisk/speichersoc-live.graph
fi
if [[ socmodul1 != "none" ]]; then
	echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/soc1-live.graph)" > /var/www/html/openWB/ramdisk/soc1-live.graph
fi
mosquitto_pub -t openWB/graph/alllivevalues -r -m "$(cat /var/www/html/openWB/ramdisk/all-live.graph | tail -n 80)" &
mosquitto_pub -t openWB/graph/lastlivevalues -r -m "$(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$verbraucher3_watt,$ladeleistunglp3,$ladeleistunglp4,$ladeleistunglp5,$ladeleistunglp6,$ladeleistunglp7,$ladeleistunglp8" &
mosquitto_pub -t openWB/graph/1alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"0" | head -n "$((100 - 0))")" &
mosquitto_pub -t openWB/graph/2alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"100" | head -n "$((200 - 100))")" &
mosquitto_pub -t openWB/graph/3alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"200" | head -n "$((300 - 200))")" &
mosquitto_pub -t openWB/graph/4alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"300" | head -n "$((400 - 300))")" &
mosquitto_pub -t openWB/graph/5alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"400" | head -n "$((500 - 400))")" &
mosquitto_pub -t openWB/graph/6alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"500" | head -n "$((600 - 500))")" &
mosquitto_pub -t openWB/graph/7alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"600" | head -n "$((700 - 600))")" &
mosquitto_pub -t openWB/graph/8alllivevalues -r -m "$(< ramdisk/all-live.graph tail -n +"700" | head -n "$((800 - 700))")" &



#Long Time Graphing
if (( graphtimer == 1 )); then
	echo $((pvwatt * -1)) >> /var/www/html/openWB/ramdisk/pv.graph
	echo $wattbezugint >> /var/www/html/openWB/ramdisk/evu.graph
	echo $soc >> /var/www/html/openWB/ramdisk/soc.graph
	echo $ladeleistung >> /var/www/html/openWB/ramdisk/ev.graph
	if (( speichervorhanden == 1 )); then
		echo $speicherleistung >> /var/www/html/openWB/ramdisk/speicher.graph
		echo $speichersoc >> /var/www/html/openWB/ramdisk/speichersoc.graph
	fi
	if [[ socmodul1 != "none" ]]; then
		echo $soc1 >> /var/www/html/openWB/ramdisk/soc1.graph
	fi
	echo $ladeleistunglp1 >> /var/www/html/openWB/ramdisk/ev1.graph
	echo $hausverbrauch >> /var/www/html/openWB/ramdisk/hausverbrauch.graph
	if (( lastmanagement == 1 )); then
		echo $ladeleistunglp2 >> /var/www/html/openWB/ramdisk/ev2.graph
	fi
	if (( verbraucher1_aktiv == 1 )); then
		echo $verbraucher1_watt >> /var/www/html/openWB/ramdisk/verbraucher1.graph
	fi
	if (( verbraucher2_aktiv == 1 )); then
		echo $verbraucher2_watt >> /var/www/html/openWB/ramdisk/verbraucher2.graph
	fi
	if (( verbraucher3_aktiv == 1 )); then
		echo $verbraucher3_watt >> /var/www/html/openWB/ramdisk/verbraucher3.graph
	fi
	if (( dpseed == "3" )); then
		livegraphtime="240"
	else
		livegraphtime="720"
	fi
	date +%H:%M >> /var/www/html/openWB/ramdisk/time.graph
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/pv.graph)" > /var/www/html/openWB/ramdisk/pv.graph
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/evu.graph)" > /var/www/html/openWB/ramdisk/evu.graph
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/soc.graph)" > /var/www/html/openWB/ramdisk/soc.graph
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/ev.graph)" > /var/www/html/openWB/ramdisk/ev.graph 
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/ev1.graph)" > /var/www/html/openWB/ramdisk/ev1.graph
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/hausverbrauch.graph)" > /var/www/html/openWB/ramdisk/hausverbrauch.graph
	if (( verbraucher1_aktiv == 1 )); then
		echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/verbraucher1.graph)" > /var/www/html/openWB/ramdisk/verbraucher1.graph 
	fi
	if (( verbraucher2_aktiv == 1 )); then
		echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/verbraucher2.graph)" > /var/www/html/openWB/ramdisk/verbraucher2.graph 
	fi
	if (( verbraucher3_aktiv == 1 )); then
		echo "$(tail -$livegraph /var/www/html/openWB/ramdisk/verbraucher3.graph)" > /var/www/html/openWB/ramdisk/verbraucher3.graph 
	fi
	if (( lastmanagement == 1 )); then	
		echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/ev2.graph)" > /var/www/html/openWB/ramdisk/ev2.graph 
	fi
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/time.graph)" > /var/www/html/openWB/ramdisk/time.graph
	if ((speichervorhanden == 1 )); then
		echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/speicher.graph)" > /var/www/html/openWB/ramdisk/speicher.graph
		echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/speichersoc.graph)" > /var/www/html/openWB/ramdisk/speichersoc.graph
	fi
	if [[ socmodul1 != "none" ]]; then
		echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/soc1.graph)" > /var/www/html/openWB/ramdisk/soc1.graph
	fi
	#beta testing
	echo $(date +%H:%M:%S),$wattbezugint,$ladeleistung,$pvgraph,$ladeleistunglp1,$ladeleistunglp2,$ladeleistung,$speicherleistung,$speichersoc,$soc,$soc1,$hausverbrauch,$verbraucher1_watt,$verbraucher2_watt,$verbraucher3_watt >> /var/www/html/openWB/ramdisk/all.graph
	echo "$(tail -$livegraphtime /var/www/html/openWB/ramdisk/all.graph)" > /var/www/html/openWB/ramdisk/all.graph
	#end beta testing
fi
}
