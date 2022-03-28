/************************* Libraries *************************/
#if defined(__AVR__)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>

const char * ssid = "ENVYROB113004";
const char * password = "0j085693";
const char * mqtt_server = "192.168.137.1";

#endif
#include <SoftwareSerial.h>
#include <Wire.h>

#include <Servo.h>

#include <HX711_ADC.h> // Library for operating the scales.
#include <LiquidCrystal.h> // Library for operating the LCD display.
#include <PubSubClient.h>


/************************* DC-motors *************************/
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

/************************* Servos *************************/
Servo servoOne;
const uint8_t SERVO1_PIN = 9; // Not known yet
uint8_t servoOneState = 90;

Servo servoTwo;
const uint8_t SERVO2_PIN = 0; // Not known yet
uint8_t servoTwoState = 90;

Servo servoThree;
const uint8_t SERVO3_PIN = 0; // Not known yet
uint8_t servoThreeState = 90;

/************************* LCD *************************/

const uint8_t LCDRS_PIN = 50;
const uint8_t LCDE_PIN = 49;
const uint8_t LCDDB4_PIN = 46;
const uint8_t LCDDB5_PIN = 52;
const uint8_t LCDDB6_PIN = 47;
const uint8_t LCDDB7_PIN = 45;



/************************* Sensors *************************/
const uint8_t UTRIG_PIN = 10;
const uint8_t UECHO_PIN = 8;

const uint8_t LEDR_PIN = 9;
const uint8_t LEDG_PIN = 10;
const uint8_t LEDB_PIN = 11;

const uint8_t KS2_PIN = 14;
const uint8_t KS3_PIN = 19;
const uint8_t KOUT_PIN = 38;

const uint8_t WSDA_PIN = 20;
const uint8_t WSCL_PIN = 21;

LiquidCrystal lcd(LCDRS_PIN, LCDE_PIN, LCDDB4_PIN, LCDDB5_PIN, LCDDB6_PIN, LCDDB7_PIN);


/************************* Reset function *************************/
void(* resetFunc) (void) = 0;

/************************* Miscellaneous ***********************/
uint8_t orderState = 1;
bool proceedNormalFlow = false;

long lastReadingTimeWeight = 0;
long lastReadingTimeDistance = 0;
long lastReadingTimeColor = 0;

uint8_t calibrationFactor = 1;

String message = "";
String topic;
String messageString;

String sendMessage = "";

char rdata;
String incomingSerial;

/*****************************************************************/

void setup() {
  /************************* DC-motors *************************/
  pinMode(MOTOR1_PIN, OUTPUT);
  pinMode(MOTOR2_PIN, OUTPUT);
  pinMode(MOTOR3_PIN, OUTPUT);

  pinMode(MOTOR1_RELAY_PIN, OUTPUT);
  pinMode(MOTOR2_RELAY_PIN, OUTPUT);
  pinMode(MOTOR3_RELAY_PIN, OUTPUT);

  /************************* Servos *************************/
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

}

void loop() {
  delay(100);
  if (topic != "" && messageString != "") {
    manualFlow(topic, messageString);
    message = "";
    messageString = "";
    topic = ""; 
  }
}

/************************* Helpers *************************/
uint8_t getMotorVoltage(uint8_t motorVoltage = MOTOR_VOLTAGE) {
  return map(motorVoltage, 0, 12, 0, 255);
}

// Method for calibrating the weight sensor.
void calibrateScale() {
  const uint8_t calibrationWeight = 100;
  // Used as disposable variable for calibrating the weight sensor.
  uint8_t count = 0;

  HX711_ADC LoadCell(WSDA_PIN, WSCL_PIN);

  lcd.clear();
  lcd.print("Please put " + String(calibrationWeight) + "g on the sensor.");

  // Used to display the message on the LCD until the user puts something on the scale.
  while (count < 1000) {
    LoadCell.update();
    count = LoadCell.getData();
  }

  lcd.clear();
  lcd.print("Please wait...");

  // Used to get an accurate result for the calibrationFactor.
  for (int i = 0; i < 100; i++) {
    LoadCell.update();
    count = LoadCell.getData();
    calibrationFactor = count / calibrationWeight;
  }

  lcd.print("Calibration complete.");
  delay(1000);
  lcd.clear();
}

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
void readWeight() {
  String weight = "0";
  float weightInt = 0.0;

  HX711_ADC LoadCell(WSDA_PIN, WSCL_PIN);
  LoadCell.begin(); // Starts  connection to the weight sensor.
  LoadCell.start(2000); // Sets the time the sensor gets to configure
  calibrateScale();
  LoadCell.setCalFactor(calibrationFactor); // Calibaration

  LoadCell.update(); // gets data from load cell
  weightInt = LoadCell.getData(); // gets output values
  weight = String(weightInt);

  // Printing the weight to the LCD screen.

  // If one second has passed, weight is updated.
  if (weight != "0" && (millis() - lastReadingTimeWeight) > 1000) {
    if (orderState == 1) {
      lastReadingTimeWeight = millis();
      sendMessage = "weight1_" + weight;
    } else if (orderState == 2) {
      lastReadingTimeWeight = millis();
      sendMessage = "weight2_" + weight;
    } else {
      sendMessage = "weight_error";
    }
  }
}

/************************* Read color sensor and publish *************************/
void readColor() {
  uint8_t red = "0";
  uint8_t green = "0";
  uint8_t blue = "0";

  String redString;
  String greenString;
  String blueString;

  digitalWrite(KS2_PIN, LOW);
  digitalWrite(KS3_PIN, LOW);
  red = pulseIn(KOUT_PIN, LOW);
  redString = String(red);
  if (redString.length() == 1) {
    redString = "00" + redString;
  } else if (redString.length() == 2) {
    redString = "0" + redString;
  }

  digitalWrite(KS2_PIN, HIGH);
  digitalWrite(KS3_PIN, HIGH);
  green = pulseIn(KOUT_PIN, LOW);
  greenString = String(green);
  if (greenString.length() == 1) {
    greenString = "00" + greenString;
  } else if (greenString.length() == 2) {
    greenString = "0" + greenString;
  }

  digitalWrite(KS2_PIN, LOW);
  digitalWrite(KS3_PIN, HIGH);
  blue = pulseIn(KOUT_PIN, LOW);
  blueString = String(blue);
  if (blueString .length() == 1) {
    blueString  = "00" + blueString ;
  } else if (blueString.length() == 2) {
    blueString  = "0" + blueString ;
  }

  String color = redString + greenString + blueString;
  
  if ((millis() - lastReadingTimeColor) > 500) {
    lastReadingTimeColor = millis();
    sendMessage = sendMessage + color;
    Serial.println(color);
  }
}

/************************* Read ultrasonic sensor *************************/
void readUltrasonic() {
  sendMessage = "ultra_";
  uint8_t theta = servoOneState;
  uint16_t radius = 0;
  const uint8_t cilinderOffset = 2;
  double duration;
  double distance;

  // Clears the condition on the trig pin.
  digitalWrite(UTRIG_PIN, LOW);
  delayMicroseconds(2);

  // Sets the trig pin active for 10 microseconds.
  digitalWrite(UTRIG_PIN, HIGH);
  delayMicroseconds(10);
  // Mesures the time the sound wave traveled.
  duration = pulseIn(UECHO_PIN, HIGH);
  // Gives the distance in cm.
  distance = duration * 0.034 / 2;
  distance = distance + cilinderOffset;

  if (distance > 0 && (millis() - lastReadingTimeDistance) > 500) {
    lastReadingTimeDistance = millis();
    sendMessage = sendMessage + String(distance);
    Serial.println(distance);
  }
}

/************************* Program flow *************************/
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
    // Constrain angle between 0-180 degrees, 90 degrees is default state (silo 2)

    servoOne.write(angle);
    servoOneState = angle;
    sendMessage = sendMessage + angle;
    // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

  }
  else if (topic == "servo2") {
    uint8_t angle = messageString.toInt();
    // Constrain angle between 0-180 degrees, 90 degrees is default state (silo 2)

    servoTwo.write(angle);
    servoTwoState = angle;
    // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

  }
  else if (topic == "servo3") {
    uint8_t angle = messageString.toInt();
    // Constrain angle between 0-180 degrees, 90 degrees is default state (silo 2)

    servoThree.write(angle);
    servoThreeState = angle;
    // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

  }
  // Weight data
  else if (topic == "weight1") {
    lcd.setCursor(0, 1);
    lcd.print(messageString);
  }

  else if (topic == "weight2") {
    lcd.setCursor(0, 1);
    lcd.print(messageString);
  }

  else if (topic == "ultra" && messageString == "read") {
    readUltrasonic();
  }

  else if (topic == "readColor" && messageString == "read_color") {
    readColor();
  }

  else {
    sendMessage = "topic error";
  }
}

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

}

// function that executes whenever data is requested from master

void sendText(int numBytes) {
  if (sendMessage != "") {
    while (sendMessage.length() != 32) {
      sendMessage = sendMessage + "@";
    }
    Wire.write(sendMessage.c_str());
  }
  sendMessage = "";
}
