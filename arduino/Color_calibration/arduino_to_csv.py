import serial
from datetime import datetime
import time
import csv
import os

def read_serial():
    arduino_port = "/dev/ttyACM0" 
    baud = 9600
    file = "test_data.csv"
    i = 0
    datamatrix = []
    samples = 20


    ser = connect_to_serial(arduino_port, baud)
    # Gets 20 serial outputs of the Arduino.
    while(i < samples):
        ser_bytes = ser.readline()
        datamatrix.append([time_now(), ser_bytes.decode("utf-8").strip()])
        i+=1
        print("\r" +  f'Getting data... ({i}/{samples})', end="\r")
        
    write_csv(file, datamatrix)
    open_file()

def connect_to_serial(port, baud):
    try:
        serial.Serial(port, baud)
    except Exception:
        print('Connection failed. Please try again.')
    else:
        print('Connection established.')
        return serial.Serial(port, baud)
        
    
    
def time_now():
    # Tested, it works.
    now = datetime.now()
    hour = now.hour
    while(len(str(hour)) != 2):
        hour = '0' + str(hour)
    minutes = now.minute
    while(len(str(minutes)) != 2):
        minutes = '0' + str(minutes)
    seconds = now.second
    while(len(str(seconds)) != 2):
        minutes = '0' + str(seconds)
    microseconds = now.microsecond
    return f"{hour}:{minutes}:{seconds}.{str(microseconds)[0:3]}"


def write_csv(file, matrix):
    # Tested, it works. 
    fields = ['Timestamp', 'distance']

    with open(file, 'w') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(fields) 
        csvwriter.writerows(matrix)


def open_file():
    input_string = input('Would you like to open the file? (Y/N)')

    if input_string.lower() == 'y':
        os.popen('gedit test_data.csv')
    else:
        return

if __name__ == '__main__':
    read_serial()
