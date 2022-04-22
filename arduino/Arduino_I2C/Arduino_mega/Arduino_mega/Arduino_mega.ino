/************************* Libraries *************************/
#if defined(__AVR__)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>

const char * ssid = "ENVYROB113004";
const char * password = "0j085693";
const char * mqtt_server = "10.45.66.58";

#endif
#include <SoftwareSerial.h>
#include <Wire.h>

#include <Servo.h>

#include <DFRobot_HX711_I2C.h> // KUL library

#include <HX711_ADC.h> // Library for operating the scales.
#include <LiquidCrystal.h> // Library for operating the LCD display.
#include <PubSubClient.h>

/************************* Pins and variables *************************/
// DC-motors
const uint8_t MOTOR_VOLTAGE = 2;

const uint8_t MOTOR1_PIN = 2;
const uint8_t MOTOR1_RELAY_PIN = 24;
uint8_t motorOneState = LOW;
bool motorOneClockwise = true;

const uint8_t MOTOR2_PIN = 3;
const uint8_t MOTOR2_RELAY_PIN = 26;
uint8_t motorTwoState = LOW;
bool motorTwoClockwise = true;

const uint8_t MOTOR3_PIN = 4;
const uint8_t MOTOR3_RELAY_PIN = 27;
uint8_t motorThreeState = LOW;
bool motorThreeClockwise = true;

// Servos
Servo servoOne;
const uint8_t SERVO1_PIN = 9; // Not known yet
uint8_t servoOneState = 90;

Servo servoTwo;
const uint8_t SERVO2_PIN = 0; // Not known yet
uint8_t servoTwoState = 90;

Servo servoThree;
const uint8_t SERVO3_PIN = 0; // Not known yet
uint8_t servoThreeState = 90;

// LCD
const uint8_t LCDRS_PIN = 50;
const uint8_t LCDE_PIN = 49;
const uint8_t LCDDB4_PIN = 46;
const uint8_t LCDDB5_PIN = 52;
const uint8_t LCDDB6_PIN = 47;
const uint8_t LCDDB7_PIN = 45;
LiquidCrystal lcd(LCDRS_PIN, LCDE_PIN, LCDDB4_PIN, LCDDB5_PIN, LCDDB6_PIN, LCDDB7_PIN);

// Ultrasonic Sensor
const uint8_t UTRIG_PIN = 10;
const uint8_t UECHO_PIN = 8;
uint8_t ultrasonicState = LOW;
long lastReadingTimeDistance = 0;

// RGB-led
const uint8_t LEDR_PIN = 9;
const uint8_t LEDG_PIN = 10;
const uint8_t LEDB_PIN = 11;

// Color Sensor
const uint8_t KS2_PIN = 14;
const uint8_t KS3_PIN = 19;
const uint8_t KOUT_PIN = 38;
uint8_t colorState = LOW;
long lastReadingTimeColor = 0;

// Weight sensor
// DFRobot_HX711_I2C MyScale(&Wire,/*addr=*/0x64);
DFRobot_HX711_I2C MyScale;
uint8_t weightState = LOW;
long lastReadingTimeWeight = 0;

// Sending over wire
String sendMessage = "";

// Receiving over wire
String message = "";
String topic;
String messageString;


// Miscellaneous
uint8_t orderState = 1;
bool proceedNormalFlow = false;


void setup() {
  /************************* Variables *************************/
  // DC-motors
  pinMode(MOTOR1_PIN, OUTPUT);
  pinMode(MOTOR2_PIN, OUTPUT);
  pinMode(MOTOR3_PIN, OUTPUT);

  pinMode(MOTOR1_RELAY_PIN, OUTPUT);
  pinMode(MOTOR2_RELAY_PIN, OUTPUT);
  pinMode(MOTOR3_RELAY_PIN, OUTPUT);

  // Servos
  servoOne.attach(SERVO1_PIN);
  servoTwo.attach(SERVO2_PIN);
  servoThree.attach(SERVO3_PIN);

  servoOne.write(servoOneState);

  /************************* Color sensor *************************/
  pinMode(KOUT_PIN, INPUT);
  pinMode(KS2_PIN, OUTPUT);
  pinMode(KS3_PIN, OUTPUT);

  /************************* Weight sensor *************************/
  pinMode(UTRIG_PIN, OUTPUT);
  pinMode(UECHO_PIN, INPUT);

  /************************* Node MCU  *************************/
  Wire.begin(8);
  Wire.onReceive(receiveEvent);
  Wire.onRequest(sendText);
  Serial.begin(115200);

  digitalWrite(MOTOR1_PIN, LOW);

  lcd.begin(16, 2);
  lcd.setCursor(0, 0);
  lcd.print("Weight [g]:");

  // Initializing and calibrating the weight sensor.
  while (!MyScale.begin()) {
    Serial.println("The initialization of the chip is failed, please confirm whether the chip connection is correct");
    delay(1000);
  }

  MyScale.setCalWeight(100);
  MyScale.setThreshold(50);

  delay(2000);
  MyScale.enableCal();
  long time1 = millis();

  while (!MyScale.getCalFlag()) {
    if ((millis() - time1) > 7000) {
      Serial.println("Calibration failed, no weight was detected on the scale");
    }
    delay(1000);
  }
  Serial.print("The calibration value of the sensor is: ");
  Serial.println(MyScale.getCalibration());
  MyScale.setCalibration(MyScale.getCalibration());
  delay(1000);
  MyScale.peel();

}

void loop() {
  delay(100);

  if (message != "" and topic != "") {
    manualFlow(topic, messageString);
  }

  message = "";
  messageString = "";
  topic = "";
}
/************************* Program flows *************************/
void manualFlow(String topic, String messageString) {
  sendMessage = "log_";

  // Motors
  if (topic == "motor1") {
    if (messageString == "toggle" && motorOneState == LOW) {
      sendMessage = sendMessage + "on";
      analogWrite(MOTOR1_PIN, getMotorVoltage());
      motorOneState = HIGH;
    } else if (messageString == "toggle" && motorOneState == HIGH) {
      sendMessage = sendMessage + "off";
      analogWrite(MOTOR1_PIN, 0);
      motorOneState = LOW;
    } else if (messageString == "turn") {
      if (motorOneClockwise == true) {
        changeMotorRotation(MOTOR1_PIN, MOTOR1_RELAY_PIN, motorOneState, motorOneClockwise);
        motorOneClockwise = false;
      } else {
        changeMotorRotation(MOTOR1_PIN, MOTOR1_RELAY_PIN, motorOneState, motorOneClockwise);
        motorOneClockwise = true;
      }
      sendMessage = sendMessage + "turn";
    } else {
      sendMessage = sendMessage + "topic error";
    }
  } else if (topic == "motor2") {
    if (messageString == "toggle" && motorTwoState == LOW) {
      sendMessage = sendMessage + "on";
      analogWrite(MOTOR2_PIN, getMotorVoltage());
      motorTwoState = HIGH;
    } else if (messageString == "toggle" && motorTwoState == HIGH) {
      sendMessage = sendMessage + "off";
      analogWrite(MOTOR2_PIN, 0);
      motorTwoState = LOW;
    } else if (messageString == "turn") {
      changeMotorRotation(MOTOR2_PIN, MOTOR2_RELAY_PIN, motorTwoState, motorTwoClockwise);
      sendMessage = sendMessage + "turn";
    } else {
      sendMessage = sendMessage + "message error";
    }
  } else if (topic == "motor3") {
    if (messageString == "toggle" && motorThreeState == LOW) {
      sendMessage = sendMessage + "on";
      analogWrite(MOTOR3_PIN, getMotorVoltage());
      motorThreeState = HIGH;
    } else if (messageString == "toggle" && motorThreeState == HIGH) {
      sendMessage = sendMessage + "off";
      analogWrite(MOTOR3_PIN, 0);
      motorThreeState = LOW;
    } else if (messageString == "change_rotation") {
      changeMotorRotation(MOTOR3_PIN, MOTOR3_RELAY_PIN, motorThreeState, motorThreeClockwise);
      sendMessage = sendMessage + "change rotation";

    } else {
      sendMessage = sendMessage + "message error";
    }
  }

  //Servos
  else if (topic == "servo1") {
    uint8_t angle = messageString.toInt();

    servoOne.write(angle);
    servoOneState = angle;
    sendMessage = sendMessage + angle;
  }
  else if (topic == "servo2") {
    uint8_t angle = messageString.toInt();
    
    servoTwo.write(angle);
    servoTwoState = angle;
  }
  else if (topic == "servo3") {
    uint8_t angle = messageString.toInt();

    servoThree.write(angle);
    servoThreeState = angle;
  }

  // Weight data
  else if (topic == "weight1") {
    lcd.clear();
    lcd.setCursor(0, 1);
    lcd.print(messageString);
  }

  else if (topic == "weight2") {
    lcd.clear();
    lcd.setCursor(0, 1);
    lcd.print(messageString);
  }

  else if (topic == "colorControl") {
    if (messageString == "readColor" && colorState == LOW) {
      colorState = HIGH;
      readColor();
    } else if (messageString == "readColor" && colorState == HIGH || messageString == "stopColor") {
      colorState = LOW;
    }
  }

  else if (topic == "distControl") {
    if (messageString == "readDist" && ultrasonicState == LOW) {
      ultrasonicState = HIGH;
      readUltrasonic();
    } else if (messageString == "readDist" && ultrasonicState == HIGH || messageString == "stopDist") {
      ultrasonicState = LOW;
    }
  }

  else if (topic == "weightControl") {
    if (messageString == "readWeight" && ultrasonicState == LOW) {
      ultrasonicState = HIGH;
      readUltrasonic();
    } else if (messageString == "readWeight" && ultrasonicState == HIGH || messageString == "stopUltra") {
      ultrasonicState = LOW;
    }
  }

  else {
    sendMessage = "topic error";
  }

}

/************************* Helpers *************************/
uint8_t getMotorVoltage(uint8_t motorVoltage = MOTOR_VOLTAGE) {
  return map(motorVoltage, 0, 12, 0, 255);
}

/************************* Voids *************************/
// Changes the rotation of the motor, keeps the state at its original level.
void changeMotorRotation(const uint8_t motorPin, const uint8_t motorRelayPin, uint8_t motorState, bool motorClockwise) {
  if (motorClockwise == true) {
    if (motorState == HIGH) {
      // Stops the motor when the motor is spinning.
      analogWrite(motorPin, 0);
      // Wait for the motor to stop.
      delay(1000);
      // Switch the relay.
      digitalWrite(motorRelayPin, HIGH);
      // Wait for the relay to switch.
      delay(2000);
      // Spins the motor in the other direction.
      analogWrite(motorPin, getMotorVoltage());
    } else if (motorState == LOW) {
      // Switch the relay.
      digitalWrite(motorRelayPin, HIGH);
      delay(500);
    }
  }
  else if (motorClockwise == false) {
    if (motorState == HIGH) {
      // Stops the motor when the motor is spinning.
      analogWrite(motorPin, 0);
      // Wait for the motor to stop.
      delay(1000);
      // Switch the relay.
      digitalWrite(motorRelayPin, LOW);
      // Wait for the relay to switch.
      delay(2000);
      // Spins the motor in the other direction.
      analogWrite(motorPin, getMotorVoltage());
    } else if (motorState == LOW) {
      // Switch the relay.
      digitalWrite(motorRelayPin, LOW);
      delay(500);
    }
  }
}

/************************* Read weight sensor and publish *************************/
void readScaleWeight() {
  while (weightState == HIGH) {
    if ((millis() - lastReadingTimeWeight) > 1000 && weightState == HIGH) {
      // Used for clearing the cache of those variables. 
      message = "";
      messageString = "";
      topic = "";
      lastReadingTimeWeight = millis();

      String weight = "0";
      float weightInt = 0.0;

      weightInt = MyScale.readWeight(); // gets output values from the scale
      weight = String(weightInt);

      // If one second has passed, weight is updated.

      if (orderState == 0) {
        sendMessage = "weightData_" + weight;
      }
      else if (orderState == 1) {
        sendMessage = "weight1_" + weight;
      } 
      else if (orderState == 2) {
        sendMessage = "weight2_" + weight;
      } 
      else {
        sendMessage = "log_" + "orderStateBoundError";
      }

    }
  }
}

/************************* Read color sensor and publish *************************/
void readColor() {
  while (colorState == HIGH) {
    if ((millis() - lastReadingTimeColor) > 1000 && colorState == HIGH) {
      // Used for clearing the cache of those variables. 
      message = "";
      messageString = "";
      topic = "";
      lastReadingTimeColor = millis();

      uint8_t red = "0";
      uint8_t green = "0";
      uint8_t blue = "0";

      String redString;
      String greenString;
      String blueString;

      // Red
      digitalWrite(KS2_PIN, LOW);
      digitalWrite(KS3_PIN, LOW);
      red = pulseIn(KOUT_PIN, LOW);
      redString = String(red);
      if (redString.length() == 1) {
        redString = "00" + redString;
      } else if (redString.length() == 2) {
        redString = "0" + redString;
      }

      // Green
      digitalWrite(KS2_PIN, HIGH);
      digitalWrite(KS3_PIN, HIGH);
      green = pulseIn(KOUT_PIN, LOW);
      greenString = String(green);
      if (greenString.length() == 1) {
        greenString = "00" + greenString;
      } else if (greenString.length() == 2) {
        greenString = "0" + greenString;
      }

      // Blue
      digitalWrite(KS2_PIN, LOW);
      digitalWrite(KS3_PIN, HIGH);
      blue = pulseIn(KOUT_PIN, LOW);
      blueString = String(blue);
      if (blueString .length() == 1) {
        blueString  = "00" + blueString ;
      } else if (blueString.length() == 2) {
        blueString  = "0" + blueString ;
      }

      // Publish
      if (orderState == 0) {
        sendMessage = "colorData_" + redString + greenString + blueString;
      }
      else if (orderState == 1) {
        sendMessage = "color1_" + redString + greenString + blueString;
      }
      else if (orderState == 2) {
        sendMessage = "color2_" + redString + greenString + blueString;
      }
      else {
        sendMessage = "log_" + "orderStateBoundError"
      }

    }
  }
}

/************************* Read ultrasonic sensor and publish*************************/
void readUltrasonic() {
  while (ultrasonicState == HIGH) {
    if ((millis() - lastReadingTimeDistance) > 1000 && ultrasonicState == HIGH) {
      // Used for clearing the cache of those variables. 
      message = "";
      messageString = "";
      topic = "";
      lastReadingTimeDistance = millis();

      uint8_t theta = servoOneState;
      uint16_t radius = 0;
      const uint8_t cilinderOffset = 2;
      double duration;
      double distance;

      digitalWrite(UTRIG_PIN, LOW);
      delayMicroseconds(2);

      digitalWrite(UTRIG_PIN, HIGH);
      delayMicroseconds(10);

      duration = pulseIn(UECHO_PIN, HIGH);
      distance = duration * 0.034 / 2;
      distance = distance + cilinderOffset;

      // Publish
      sendMessage = "distData_" + String(distance);
    }
    delay(100);
  }
}

// Receives wire events.
void receiveEvent(int howMany) {
  while (0 < Wire.available()) {
    char c = Wire.read();
    message = message + c;
  }

  int indexDelimiter = message.indexOf('_');

  if (indexDelimiter == -1) {
    Serial.println(message);
  }
  else {
    topic = message.substring(0, indexDelimiter);
    messageString = message.substring(indexDelimiter + 1, message.length());
    delay(100);
  }

  //  // For receiving topics via Wire.
  //  if (topic == "distControl") {
  //    if (messageString == "readDist" && ultrasonicState == HIGH || messageString == "stopDist") {
  //      ultrasonicState = LOW;
  //    }
  //  }
  //
  //  else if (topic == "colorControl") {
  //    if (messageString == "readColor" && colorState == HIGH || messageString == "stopColor") {
  //      colorState = LOW;
  //    }
  //  }
  //
  //  else if (topic == "weightControl") {
  //    if (messageString == "readWeight" && colorState == HIGH || messageString == "stopWeight") {
  //      weightState = LOW;
  //    }
  //  }

  Serial.println(message);
  Serial.println(messageString);
  Serial.println(topic);
}

// Function that executes whenever data is requested from master.
void sendText(int numBytes) {
  if (sendMessage != "") {
    while (sendMessage.length() != 32) {
      sendMessage = sendMessage + "@";
    }
    Wire.write(sendMessage.c_str());
  }
  sendMessage = "";
}
