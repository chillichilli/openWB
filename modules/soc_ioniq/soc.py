import serial
#import MySQLdb
import re
import time
import string
import io
import time

import struct

# write value to file on ramdisk
def writefile(filename, value):
    f = open( "/var/www/html/openWB/ramdisk/"+filename, "w+")
    f.write(str(value))
    f.close()

# hex string to signed integer
def htosi(val):
    #print "val:%s." % val
    val2=int(val, 16)
    #print val2
    if val2>=32768:
        val2=val2-65535
    #print val2
    # python3: 
    #uintval = struct.unpack('>i', bytes.fromhex(val))
    return val2

#db = MySQLdb.connect(host="<DB HOST>",    # your host, usually localhost
#                     user="<DB USER>",         # your username
#                     passwd="<DB PASSWORT>",  # your password
#                     db="<DB NAME>")        # name of the data base

#cur = db.cursor()

ser = serial.Serial("/dev/rfcomm0", timeout=3) #None)
#ser = serial.Serial("/dev/rfcomm2", timeout=None)
ser.baudrate = 9600


#print "2105 ---------------------------"

ser.flushInput()
ser.write(b'2105\r\n')
ser.flush()
seq = []
while True:
    reading = ser.read()
    seq.append(reading)
    joineddata = ' '.join(str(v) for v in seq).replace(' ', '')

    #print "2105: reading %s" % joineddata

    err = re.search('ERROR', joineddata)
    nodata = re.search('NODATA', joineddata)
    bufferfull = re.search('BUFFERFULL', joineddata)
    if err or nodata or bufferfull:
        #print "NODATA !"
        break
    

    m = re.findall('4:(.*)5:', joineddata) #'/4([^;]*)\n5', joineddata)
    if m:
#        ser.close()
        x = m[0][-15:]
        #print "4: %s" % x
        #(test[-8:])      
        SoCS = x[12:14]   
        #print "SoCS: %s" % SoCS
        SoC = int(int( SoCS, 16)/2)    #*0.5
        if (SoC > 0) and (SoC <= 100):
            print("%s"  % SoC)
            writefile("soc", int(SoC))
            writefile("soctime", int(now)) 
#            cur.execute("""INSERT INTO bms (soc) VALUES (%s)""", (SoC,) )
#            db.commit()
       
        #SoH = (int(x[0:1],16)/10)
        SoH1 = x[0:2]
        SoH2 = x[2:4]
        SoH3 = x[0:4]
        #print "SoH3: %s" % SoH3
        SoH = int(SoH3, 16) * 0.1
        #print "SoH: %s" % SoH

        break

ser.close()

