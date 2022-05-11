/************************* Libraries *************************/
#include <Wire.h>
#include <Servo.h>
#include <DFRobot_HX711_I2C.h> // KUL library
#include <LiquidCrystal.h> // Library for operating the LCD display.
#include <PubSubClient.h>

/************************* Pins and variables *************************/
// DC-motors
const uint8_t MOTOR_VOLTAGE = 12;

const uint8_t MOTOR1_PIN = 9;
const uint8_t MOTOR1_RELAY_PIN = 24;
uint8_t motorOneState = LOW;
bool motorOneClockwise = true;

const uint8_t MOTOR2_PIN = 8;
const uint8_t MOTOR2_RELAY_PIN = 26;
uint8_t motorTwoState = LOW;
bool motorTwoClockwise = true;

// Servos
Servo servoOne;
const uint8_t SERVO1_PIN = 7;
uint8_t servoOneState = 87;

Servo servoTwo;
const uint8_t SERVO2_PIN = 6;
uint8_t servoTwoState = 87;

Servo servoThree;
const uint8_t SERVO3_PIN = 5;
uint8_t servoThreeState = 90;
uint8_t servoThreeRelayState = LOW;
uint8_t servoThreeRelayPin = 35;

// LCD
const uint8_t LCDRS_PIN = 50;
const uint8_t LCDE_PIN = 39;
const uint8_t LCDDB4_PIN = 46;
const uint8_t LCDDB5_PIN = 52;
const uint8_t LCDDB6_PIN = 41;
const uint8_t LCDDB7_PIN = 43;
LiquidCrystal lcd(LCDRS_PIN, LCDE_PIN, LCDDB4_PIN, LCDDB5_PIN, LCDDB6_PIN, LCDDB7_PIN);

// Ultrasonic Sensor
const uint8_t UTRIG_PIN = 10;
const uint8_t UECHO_PIN = 17;
uint8_t ultrasonicState = LOW;
long lastReadingTimeDistance = 0;

// RGB-led
const uint8_t LEDR_PIN = 11;
const uint8_t LEDG_PIN = 13;
const uint8_t LEDB_PIN = 12;

// Color Sensor
const uint8_t KS0_PIN = 29;
const uint8_t KS1_PIN = 33;
const uint8_t KS2_PIN = 14;
const uint8_t KS3_PIN = 19;
const uint8_t KOUT_PIN = 38;
uint8_t colorState = LOW;
long lastReadingTimeColor = 0;

// Weight sensor
DFRobot_HX711_I2C MyScale(&Wire,/*addr=*/0x64);

uint8_t weightState = LOW;
long lastReadingTimeWeight = 0;

// Sending over wire
String sendMessage = "";

// Receiving over wire
String message = "";
String topic;
String messageString;


// Miscellaneous
uint8_t weightCounter = 0;
uint8_t orderState = 1;
bool proceedNormalFlow = false;
bool debug = false; // Enabled when in manualOverride color/weight/distance reading is enabled


void setup() {
  /************************* Variables *************************/
  // DC-motors
  pinMode(MOTOR1_PIN, OUTPUT);
  pinMode(MOTOR2_PIN, OUTPUT);

  pinMode(MOTOR1_RELAY_PIN, OUTPUT);
  pinMode(MOTOR2_RELAY_PIN, OUTPUT);

  pinMode(servoThreeRelayPin, OUTPUT);

  // Servos
  servoOne.attach(SERVO1_PIN);
  servoTwo.attach(SERVO2_PIN);
  servoThree.attach(SERVO3_PIN);

  digitalWrite(servoThreeRelayPin, LOW);

  servoOne.write(servoOneState);
  servoTwo.write(servoTwoState);
  servoThree.write(servoThreeState);

  /************************* Color sensor *************************/
  pinMode(KOUT_PIN, INPUT);

  pinMode(KS1_PIN, OUTPUT);
  pinMode(KS0_PIN, OUTPUT);
  pinMode(KS2_PIN, OUTPUT);
  pinMode(KS3_PIN, OUTPUT);

  // Settings the  frequency scaling (now to 20%)
  digitalWrite(KS1_PIN, LOW);
  digitalWrite(KS0_PIN, HIGH);

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
  lcd.setCursor(0, 1);
  lcd.print("0");

  //  // Starting up the weight sensor.
  //  while (weightCounter <= 5) {
  //    while (!MyScale.begin()) {
  //      Serial.println("The initialization of the chip is failed, please confirm whether the chip connection is correct");
  //      delay(1000);
  //      weightCounter ++;
  //    }
  //
  //  }
  //
  //  //Manually set the calibration values
  //  MyScale.setCalibration(2000.f);
  //  //remove the peel
  //  MyScale.peel();

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
uint8_t getMotorVoltage(uint8_t motorVoltage = MOTOR_VOLTAGE) {
  return map(motorVoltage, 0, 12, 0, 255);
}

void normalFlow(String topic, String messageString) {
  /* Variables */
  int firstSiloAngle = 0;
  int secondSiloAngle = 0;
  int thirdSiloAngle = 0;

  /* Starting the flow. */
  if (topic == 'order1') {
    // Gets the silo number and the weight from the orderString of the form siloNunber_weight
    int siloNumberFirstOrder = (messageString.substring(0, 1)).toInt();
    int orderedWeightFirstOrder = (messageString.substring(1)).toInt();
  }

  else if (topic == 'order2') {
    // Gets the silo number and the weight from the orderString of the form siloNunber_weight
    int siloNumbderSecondOrder = (messageString.substring(0, 1)).toInt();
    int orderedWeightSecondOrder = (messageString.substring(1)).toInt();
  }
}

// Sets the Bean Bot and Arduino to default position.
void section0() {
  int servoOneDefaultAngle = 0; // CHANGE!!
  int servoTwoDefaultAngle = 0; // CHANGE!!
  int servoThreeDefaultAngle = 0; // CHANGE!!

  // Writing to the servos.
  servoOne.write(servoOneDefaultAngle);
  servoTwo.write(servoTwoDefaultAngle);
  servoThree.write(servoThreeDefaultAngle);

  // Making sure the DC's are turned off.
  digitalWrite(MOTOR1_PIN, LOW);
  motorOneState = LOW;
  delay(500);
  digitalWrite(MOTOR2_PIN, LOW);
  motorTwoState = LOW;

  // Making sure no sensors are reading.
  colorState = LOW;
  ultrasonicState = LOW;
  weightState = LOW;

  // Making sure the messages are empty.
  message = "";
  messageString = "";
  topic = "";
}

// First conveyor belt moves to the correct position
void section1(int siloNumberFirstOrder) {
  int firstSiloAngle = 45;
  int secondSiloAngle = 90;
  int thirdSiloAngle = 135;

  // Sets first belt in the right angle position.
  if (siloNumberFirstOrder == 0) {
    servoOne.write(firstSiloAngle);
  }
  else if (siloNumberFirstOrder == 1) {
    servoOne.write(secondSiloAngle);
  }
  else if (siloNumberFirstOrder == 2) {
    servoOne.write(thirdSiloAngle);
  }

  // Dropping the belt onto the beans.
  int servoRotateTime = 0;
  int beltDownTime = 0; // The time the third servo has to turn in order for the first belt to be completly down.

  // Turning on the servo.
  servoThreeRelayState = LOW;
  digitalWrite(servoThreeRelayState, LOW);
  servoThree.write(85); // CHANGE !! 
  
  // Rotate for the given amount of time.
  if (millis() - servoRotateTime > beltDownTime) {
    servoRotateTime = millis();
  }
  
  // Turning off the servo.
  servoThreeRelayState = LOW;
  digitalWrite(servoThreeRelayState, LOW);
}

// Second conveyor belt moves to correct position.
void section2() {
  String angle = getAngle();
}

// Starts the two belts when they are in position.
void section3(int orderedWeight)  {
  // Starts the first DC.
  analogWrite(MOTOR1_PIN, getMotorVoltage(12));
  // Delay to spread the current peak.
  delay(1000);
  // Starts the second DC.
  analogWrite(MOTOR2_PIN, getMotorVoltage(12));

  int weight = getWeight();

  while (weight < orderedWeight) {
    // Writing the weight to the LCD.
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Weight [g]:");
    lcd.setCursor(0, 1);
    lcd.print(weight);
    delay(1000);
    // Getting the updated weight
    weight = getWeight();
  }

  // Shutting down the DC's
  analogWrite(MOTOR1_PIN, 0);
  delay(500);
  analogWrite(MOTOR2_PIN, 0);

}

/*
  Gets the angle
*/
String getAngle() {
  long distance = 0;
  int pos = 0;
  for (int pos = 0; pos <= 70; pos++) { // Change to correct angle
    distance = readDistance();
    if (distance > 14 && distance < 40) {
      break;
    }
    else {
      servoOne.write(pos); // Add or subtract some extra degrees for spacing, afhankelijk van in welke richting de servo draait
      delay(50);
    }
  }
  return String(pos);
}

// This function reads the distance 3 times and returns the average of the three values.
long readDistance() {
  long averageDistance = 0;
  int sum = 0;
  long readings[3] = {0, 0, 0};

  // Reads for three times and stores output in an array.
  for (int i = 0; i <= 3; i++) {
    double duration;
    double distance;
    digitalWrite(UTRIG_PIN, LOW);
    delayMicroseconds(2);

    digitalWrite(UTRIG_PIN, HIGH);
    delayMicroseconds(10);

    duration = pulseIn(UECHO_PIN, HIGH);
    distance = duration * 0.034 / 2;
    readings[i] = distance;
    delay(100);
  }

  // Gets the average of the three outputs.
  for (int i = 0; i < 3; i++ ) {
    sum += readings[i];
  }
  averageDistance = sum / 3;

  return averageDistance;
}

long getWeight() {
  long readings[3] = {0, 0, 0};
  long averageWeight = 0;
  long sum = 0;

  for (int i; i <= 3; i++) {
    long weightInt = MyScale.readWeight();

    readings[i] = weightInt;
  }

  // Gets the average of the three outputs.
  for (int i = 0; i < 3; i++ ) {
    sum += readings[i];
  }

  averageWeight = sum / 3;

  return averageWeight;
}


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
      if (motorTwoClockwise == true) {
        changeMotorRotation(MOTOR2_PIN, MOTOR2_RELAY_PIN, motorTwoState, motorTwoClockwise);
        motorTwoClockwise = false;
      } else {
        changeMotorRotation(MOTOR2_PIN, MOTOR2_RELAY_PIN, motorTwoState, motorTwoClockwise);
        motorTwoClockwise = true;
      }
      sendMessage = sendMessage + "turn";
    } else {
      sendMessage = sendMessage + "topic error";
    }
  }

  //Servos
  else if (topic == "servo1") {
    uint8_t angle = messageString.toInt();

    servoOneState = turnServo(servoOne, angle, servoOneState);
    sendMessage = sendMessage + angle;
  }
  else if (topic == "servo2") {
    uint8_t angle = messageString.toInt();

    servoTwoState = turnServo(servoTwo, angle, servoTwoState);
    sendMessage = sendMessage + angle;
  }
  else if (topic == "servo3") {
    uint8_t angle = messageString.toInt();

    if (angle == 0) {
      servoThreeRelayState = HIGH;
      digitalWrite(servoThreeRelayPin, HIGH);
      delay(500);
      servoThree.write(85);
    } else if (angle == 90) {
      servoThreeRelayState = LOW;
      digitalWrite(servoThreeRelayPin, LOW);
      delay(500);
      servoThree.write(87);
    } else if (angle == 80) {
      servoThreeRelayState = HIGH;
      digitalWrite(servoThreeRelayPin, HIGH);
      delay(500);
      servoThree.write(92);
    }
    servoThree.write(angle);

    sendMessage = sendMessage + angle;
  }

  // Weight data
  else if (topic == "weight1") {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Weight [g]:");
    lcd.setCursor(0, 1);
    lcd.print(messageString);
  }

  else if (topic == "weight2") {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Weight [g]:");
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
    if (messageString == "readUltra" && ultrasonicState == LOW) {
      ultrasonicState = HIGH;
      readUltrasonic();
    } else if (messageString == "readUltra" && ultrasonicState == HIGH || messageString == "stopUltra") {
      ultrasonicState = LOW;
    }
  }

  else if (topic == "weightControl") {
    if (messageString == "readWeight" && weightState == LOW) {
      weightState = HIGH;
      readScaleWeight();
    } else if (messageString == "readWeight" && weightState == HIGH || messageString == "stopWeight") {
      weightState = LOW;
    }
  } else if (topic == "debug") {
    if (messageString == "1") {
      debug = true;
    }
    else if (messageString == "0") {
      debug = false;
    }
  } else if (topic == "colorCal") {
    calibrateColor(messageString);
  } else if (topic == "rgb") {
    controlRGB(messageString);
  }
  else {
    sendMessage = "topic error";
  }

}

/************************* Helpers *************************/
// Turns the servo smoothly to the correct angle.
uint8_t turnServo(Servo servoObject, uint8_t degree, uint8_t servoState) {
  // Turn counterclockwise.
  if (degree < servoState) {
    for (int pos = servoState; pos >= degree; pos--) {
      servoObject.write(pos);
      delay(10);
    }
  }
  // Turn clockwise.
  else if (degree > servoState  ) {
    for (int pos = servoState; pos <= degree; pos++) {
      servoObject.write(pos);
      delay(10);
    }
  }

  servoState = degree;
  return servoState;
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
      if (debug) {
        sendMessage = "weightData_" + weight;
      }
      else if (orderState == 1) {
        sendMessage = "weight1_" + weight;
      }
      else if (orderState == 2) {
        sendMessage = "weight2_" + weight;
      }
      else {
        sendMessage = "log_orderStateBoundError";
      }
    }
    // Important for being capable of receiving the stop message.
    delay(250);
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
      if (debug) {
        sendMessage = "colorData_" + redString + greenString + blueString;
      }
      else if (orderState == 1) {
        sendMessage = "color1_" + redString + greenString + blueString;
      }
      else if (orderState == 2) {
        sendMessage = "color2_" + redString + greenString + blueString;
      }
      else {
      }
    }

    // Important for being capable of receiving the stop message.
    delay(250);
  }
}

String readColorCalibration() {
  // Used for clearing the cache of those variables.
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

  return redString + greenString + blueString;
}

void controlRGB(String messageString) {
  int red = messageString.substring(0, 2).toInt();
  int green = messageString.substring(3, 5).toInt();
  int blue = messageString.substring(6, 8).toInt();

  analogWrite(LEDR_PIN, red);
  analogWrite(LEDG_PIN, green);
  analogWrite(LEDB_PIN, blue);

  message = "";
  messageString = "";
  topic = "";
}

void calibrateColor(String messageString) {
  // Used for clearing the cache of those variables.

  String colorRGB = "";
  String reading1 = "";
  String reading2 = "";
  String reading3 = "";

  if (messageString == "calApp") {
    sendMessage = "colorCal_cal";
    message = "";
    messageString = "";
    topic = "";
  }
  else if (messageString.substring(0, 5) == "start") {
    colorRGB = messageString.substring(5);
    reading1 = readColorCalibration();
    delay(200);
    reading2 = readColorCalibration();
    delay(200);
    reading3 = readColorCalibration();
    sendMessage = "colorCal_stop" + colorRGB;
    message = "";
    messageString = "";
    topic = "";
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
      if (debug) {
        sendMessage = "distData_" + String(distance);
      }

    }
    // Important for being capable of receiving the stop message.
    delay(250);
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
  }
  else {
    topic = message.substring(0, indexDelimiter);
    messageString = message.substring(indexDelimiter + 1, message.length());
    delay(100);
  }

  // For receiving topics via Wire.
  if (topic == "distControl") {
    if (messageString == "readUltra" && ultrasonicState == HIGH || messageString == "stopUltra") {
      ultrasonicState = LOW;
    }
  }

  else if (topic == "colorControl") {
    if (messageString == "readColor" && colorState == HIGH || messageString == "stopColor") {
      colorState = LOW;
    }
  }

  else if (topic == "weightControl") {
    if (messageString == "readWeight" && colorState == HIGH || messageString == "stopWeight") {
      weightState = LOW;
    }
  }
  Serial.println(messageString);
  Serial.println(topic);
  Serial.println(message);
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
