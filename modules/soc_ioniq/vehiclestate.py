#!/usr/bin/python3
from pymodbus.client.sync import ModbusSerialClient
import pymodbus
from  pymodbus.payload import BinaryPayloadDecoder
import struct
from pymodbus.constants import Endian
import time

def  get_modbus_register_data(client, address, count, u):
#    print "Reading modbus Address: %s" % address
#rq = client.read_holding_registers(1000,7,unit=1)
#connection = client.connect()
#print(connection)



    tryit=True

    while tryit:
        #result = client.read_holding_registers(1002,1,unit=1)    #(address=1000,count=1,unit=1)
        try:
            result = client.read_holding_registers(address,count,unit=u)    #(address=1000,count=1,unit=1)
        except:
#            print "Exception"
            client.close()
            client = ModbusSerialClient(method = "rtu", port="/dev/rfcomm1", baudrate=9600, stopbits=1, bytesize=8, timeout=1)
            client.connect()
            time.sleep(1)
        else:   #if result.isError():
            try:
                r=result.registers[0]
                tryit=False #result.isError()
            except:
                tryit=True
 
    #print(result.registers)
    return r  #esult.registers[0]



client = ModbusSerialClient(method = "rtu", port="/dev/rfcomm1", baudrate=9600, stopbits=1, bytesize=8, timeout=1)
time.sleep(1)
client.connect()
time.sleep(1)


reg1002=get_modbus_register_data(client, 1002, 1, 1)
print reg1002

#print "1002 Vehicle State (1: ready, 2 EV is present, 3 charging, 4 charging with ventilation): %s" % get_modbus_register_data(1002, 1, 1)
#reg1001=get_modbus_register_data(1001, 1, 1)
#print "1001 Actual amps value output: %s" % reg1001
#reg2009=get_modbus_register_data(2009, 1, 1)
#print "2009 Bootloader firmware revision 2009: %s" % reg2009
#reg1005=get_modbus_register_data(1005, 1, 1)
#print "1005 Firmware revision: %s" % reg1005
#reg1003=get_modbus_register_data(1003, 1, 1)
#print "1003 Maximum current limitation PP: %s" % reg1003
#reg1000=get_modbus_register_data(1000,1,1)
#print "1000 Actual configured amps value: %s" % reg1000
#reg1004=get_modbus_register_data(1004,1,1)
#print "1004 turn off charging now: %s" % reg1004
#reg1006=get_modbus_register_data(1006,1,1)
#print "1006 EVSE state (1 steady 12V, 2 PWM generated, 3 OFF): %s" % reg1006
#reg2000=get_modbus_register_data(2000,1,1)
#print "2000 Default amps value after boot: %s" % reg2000
#reg2001=get_modbus_register_data(2001,1,1)
#print "2001 Function of PROG PIN 4+5 (0 analog inputs enabled, >0 modbus enabled slave address: %s" % reg2001
#reg2002=get_modbus_register_data(2002, 1,1)
#print "2002 Minimum amps value: %s" % reg2002
#reg2003=get_modbus_register_data(2003,1,1)
#print "2003 Analaog input config: %s" % reg2003
#reg2004=get_modbus_register_data(2004,1,1)
#print "2004 Amps settings after power on (0 do not save amps value, 1 save to reg.2000): %s" % reg2004
#reg2005=get_modbus_register_data(2005,1,1)
#print "2005 bits: %s" % reg2005
#reg2006=get_modbus_register_data(2006,1,1)
#print "2006 RFU Current sharing mode is active: %s" % reg2006
#reg2007=get_modbus_register_data(2007,1,1)
#print "2007 PP detectioni (0: PP detection enabled, >0 disabled): %s" % reg2007

#client.disconnect()
client.close()

