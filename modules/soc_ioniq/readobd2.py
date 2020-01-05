#!/usr/bin/env python3

#DF: modified evnotipi.py script from here: https://github.com/EVNotify/EVNotiPi
# Das Programm liest per UART comm Schnittstelle per bluetooth vom OBD2 Dongle des Autos die Werte SOC, SOH, 12V, kwh geladen etc. aus
#
# config.json file adjusted
# {
#    "akey": "akey",
#    "token": "token",
#    "dongle": {
#	    "type": "ELM327",
#	    "port": "/dev/rfcomm0",
#	    "speed": 9600
#    },
#    "cartype": "IONIQ_BEV"
#}


#from gpspoller import GpsPoller
#from time import sleep,time
import time
#import evnotifyapi
import json
import os
import re
import sys
import signal





def writefile(filename, value):
    f = open( "/var/www/html/openWB/ramdisk/"+filename, "w+")
    f.write(str(value))
    f.close()


LOOP_DELAY = 5
EVN_SETTINGS_DELAY = 300
ABORT_NOTIFICATION_DELAY = 60
POLL_THRESHOLD_VOLT = 13

class SKIP_POLL(Exception): pass

# load config
with open('config.json') as config_file:
    config = json.loads(config_file.read())
config['cartype']="IONIQ_BEV"
config['dongle']['type']="ELM327"
config['dongle']['port']="/dev/rfcomm0"
config['dongle']['speed']=9600


# load api lib
#EVNotify = evnotifyapi.EVNotify(config['akey'], config['token'])


if 'cartype' in config:
    cartype = config['cartype']

# Load OBD2 interface module
if not "{}.py".format(config['dongle']['type']) in os.listdir('dongles'):
    raise Exception('Unknown dongle {}'.format(config['dongle']['type']))

# Init ODB2 adapter
sys.path.insert(0, 'dongles')
exec("from {0} import {0} as DONGLE".format(config['dongle']['type']))
sys.path.remove('dongles')

# Only accept a few characters, do not trust stuff from the Internet
if re.match('^[a-zA-Z0-9_-]+$',cartype) == None:
    raise Exception('Invalid characters in cartype')

if not "{}.py".format(cartype) in os.listdir('cars'):
    raise Exception('Unknown car {}'.format(cartype))

sys.path.insert(0, 'cars')
exec("from {0} import {0} as CAR".format(cartype))
sys.path.remove('cars')


try:
    dongle = DONGLE(config['dongle'])
    car = CAR(dongle)
except:
    sys.exit(0)


# Init some variables
main_running = True
now = time.time()
last_charging = now
last_charging_soc = 0
last_data = now
last_evn_settings_poll = now

# Init SOC notifications
chargingStartSOC = 0
currentSOC = 0
socThreshold = int(config['socThreshold']) if 'socThreshold' in config else 0
notificationSent = False
abortNotificationSent = False
#print("Notification threshold: {}".format(socThreshold))



# Set up signal handling
def exit_gracefully(signum, frame):
    sys.exit(0)

signal.signal(signal.SIGTERM, exit_gracefully)

car_off_skip_poll = False

#print("Starting main loop")
try:
    while main_running:
        now = time.time()
        try:
            if car_off_skip_poll:       # Skip polling until car on voltage is detected again
                if dongle.getObdVoltage() < POLL_THRESHOLD_VOLT:
                    raise SKIP_POLL
                else:
                    print("%s readobd2: Car on detected. Resume polling." % time.strftime("%d.%m.%Y %H:%M:%S"))
                    car_off_skip_poll = False
            
            time.sleep(1)
            try:
                data = car.getData()
            except Exception as e:
                #print(time.strftime("%d.%m.%Y %H:%M:%S"), "EXCEPTION readobd2.py car.getData() ", str(e))
                raise DONGLE.NO_DATA
                #pass

            last_data = now
            is_charging = False

            #print(data)
            last_evn_transmit = now



            if 'SOC_DISPLAY' in data and 'SOC_BMS' in data:
            #    EVNotify.setSOC(data['SOC_DISPLAY'], data['SOC_BMS'])
                currentSOC = data['SOC_DISPLAY'] #or data['SOC_BMS']
                print("%s readobd2 SOC: %s" % (time.strftime("%d.%m.%Y %H:%M:%S"), currentSOC))
                writefile("soc", int(currentSOC)) # str(currentSOC).replace(".",","))
                writefile("soctime", int(now)) # str(currentSOC).replace(".",","))

            if 'EXTENDED' in data:
                #EVNotify.setExtended(data['EXTENDED'])
                is_charging = True if 'charging' in data['EXTENDED'] and \
                        data['EXTENDED']['charging'] == 1 else False
                is_connected = True if ('normalChargePort' in data['EXTENDED'] \
                        and data['EXTENDED']['normalChargePort'] == 1) \
                        or ('rapidChargePort' in data['EXTENDED'] \
                        and data['EXTENDED']['rapidChargePort'] == 1) else False

                if is_charging:
                    last_charging = now
                    last_charging_soc = currentSOC

                #print("A: ", data['EXTENDED']['dcBatteryCurrent'])
                #writefile("lla1", int(data['EXTENDED']['dcBatteryCurrent']))
                writefile("lla2", 0)
                writefile("lla3", 0)
                #print("V: ", data['EXTENDED']['dcBatteryVoltage'])
                #print("W: ", data['EXTENDED']['dcBatteryPower'])
                writefile("llaktuell", int(-1000*data['EXTENDED']['dcBatteryPower']))
                #writefile("lla"1, int(data['EXTENDED']['dcBatteryPower']/220))   # Ladeverluste
                #print("V: ", data['EXTENDED']['auxBatteryVoltage'])
                writefile("auxvoltage", int(data['EXTENDED']['auxBatteryVoltage']*10))
                #print("w: ", data['EXTENDED']['cumulativeEnergyCharged'])
                writefile("llkwh", int(1000*data['EXTENDED']['cumulativeEnergyCharged']))
                #print("%: ", data['EXTENDED']['soh'])
                #print("C: ", data['EXTENDED']['batteryMaxTemperature'])
                #print("C: ", data['EXTENDED']['externalTemperature'])


                main_running = False #DF no endless loop !

#                if False and is_charging and 'socThreshold' not in config and \
#                        now - last_evn_settings_poll > EVN_SETTINGS_DELAY:
                   # try:
                   #     s = EVNotify.getSettings()
                   #     # following only happens if getSettings is
                   #     # successful, else jumps into exception handler
                   #     settings = s
                   #     last_evn_settings_poll = now
#
#                        if s['soc'] and s['soc'] != socThreshold:
##                            socThreshold = int(s['soc'])
#                            print("New notification threshold: {}".format(socThreshold))
#
#                    except evnotifyapi.CommunicationError:
#                        pass

                # track charging started
                if is_charging and chargingStartSOC == 0:
                    chargingStartSOC = currentSOC or 0
                # check if notification threshold reached
                elif is_charging and chargingStartSOC < socThreshold and \
                    currentSOC >= socThreshold and not notificationSent:
                    print("readobd2: Notification threshold reached")
                    #EVNotify.sendNotification()
                    notificationSent = True
                elif not is_connected:   # Rearm notification
                    chargingStartSOC = 0
                    notificationSent = False
                    abortNotificationSent = False

        #except evnotifyapi.CommunicationError as e:
        #    print(e)
        except DONGLE.CAN_ERROR as e:
            #print(e)
            pass
        except DONGLE.NO_DATA as e:
            #print(e)
            volt = dongle.getObdVoltage()
            if volt and volt < POLL_THRESHOLD_VOLT:
                print("%s readobd2: Car off detected. Stop polling until car on." % time.strftime("%d.%m.%Y %H:%M:%S"))
                car_off_skip_poll = True
                main_running = False #DF no endless loop !
        except SKIP_POLL as e:
            pass
        except CAR.NULL_BLOCK as e:
            #print(e)
            pass

        finally:
            try:
                # Try to detect aborted charging
                if not abortNotificationSent \
                        and now - last_charging > ABORT_NOTIFICATION_DELAY \
                        and chargingStartSOC > 0 and last_charging_soc < socThreshold:
                    print("No response detected, send abort notification")
        #            EVNotify.sendNotification(True)
                    abortNotificationSent = True

            except evnotifyapi.CommunicationError as e:
                print("Sending of notificatin failed! {}".format(e))

            # Flush the output buffer
            sys.stdout.flush()

            if main_running:
                # Compensate for the running time of the loop
                loop_delay = LOOP_DELAY - (time.time() - now)
                if loop_delay > 0:
                    time.sleep(loop_delay)

except (KeyboardInterrupt, SystemExit): #when you press ctrl+c
    main_running = False

finally:
    #print("Exiting ...")
    pass
