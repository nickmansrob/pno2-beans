import serial
from datetime import datetime
import time
import csv
import os

def main():
    file = "test_data.csv"
    datamatrix = []
    baud = 9600
    port = "/dev/ttyACM0" 

    read_serial(300, datamatrix, port, baud)
    if datamatrix:
        write_csv(file, datamatrix)
        open_file()

    
def read_serial(samples, datamatrix, port, baud):
    i = 0
    try:
        serial.Serial(port, baud)
    except Exception:
        print(f"Connection with '{port}' on baud {baud} failed. Please try again.")
    else:
        print('Connection established.')
        ser = serial.Serial(port, baud)
        while(i < samples):
            ser_bytes = ser.readline()
            datamatrix.append([time_now()] + ser_bytes.decode("utf-8").strip().split(','))
            i+=1
            print("\r" +  f'Getting data... ({i}/{samples})', end="\r")

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
    fields = ['Timestamp', 'color', 'reading1', 'reading2', 'reading3']

    with open(file, 'w') as csvfile:
        csvwriter = csv.writer(csvfile)
        csvwriter.writerow(fields) 
        csvwriter.writerows(matrix)


def open_file():
    # Works only on Linux.
    input_string = input("Would you like to open the file (press 'N' on Windows)? (Y/N)")

    if input_string.lower() == 'y':
        os.popen('gedit test_data.csv')
    else:
        return

if __name__ == '__main__':
    main()
