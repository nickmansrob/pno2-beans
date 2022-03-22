/************************* Libraries *************************/
#if defined(__AVR__)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

#include <Servo.h>
#include <HX711_ADC.h> // Library for operating the scales.
#include <LiquidCrystal.h> // Library for operating the LCD display.
#include <PubSubClient.h>

/************************* WiFi *************************/

const char * ssid = "ENVYROB113004";
const char * password = "0j085693";
const char * mqtt_server = "192.168.137.1";

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
const uint8_t SERVO1_PIN = 0; // Not known yet
uint8_t servoOneState = 90;

Servo servoTwo;
const uint8_t SERVO2_PIN = 0; // Not known yet
uint8_t servoTwoState = 90;

Servo servoThree;
const uint8_t SERVO3_PIN = 0; // Not known yet
uint8_t servoThreeState = 90;

/************************* LCD *************************/

const uint8_t LCDRS_PIN = 48;
const uint8_t LCDE_PIN = 49;
const uint8_t LCDDB4_PIN = 50;
const uint8_t LCDDB5_PIN = 51;
const uint8_t LCDDB6_PIN = 52;
const uint8_t LCDDB7_PIN = 53;

LiquidCrystal lcd(LCDRS_PIN, LCDE_PIN, LCDDB4_PIN, LCDDB5_PIN, LCDDB6_PIN, LCDDB7_PIN);


/************************* Sensors *************************/
const uint8_t UTRIG_PIN = 8;
const uint8_t UECHO_PIN = 14;

const uint8_t LEDR_PIN = 9;
const uint8_t LEDG_PIN = 10;
const uint8_t LEDB_PIN = 11;

const uint8_t KS2_PIN = 17;
const uint8_t KS3_PIN = 18;
const uint8_t KOUT_PIN = 19;

const uint8_t WSDA_PIN = 20;
const uint8_t WSCL_PIN = 21;

/************************* MQTT *************************/
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

bool manualOverride = false;

/************************* Reset function *************************/
void(* resetFunc) (void) = 0;

/************************* Miscellaneous ***********************/
uint8_t orderState = 1;

long lastReadingTimeWeight = 0;
long lastReadingTimeDistance = 0;

uint8_t calibrationFactor = 1;


/*****************************************************************/

void setup() {
  /************************* Initializaton *************************/
  Serial.begin(115200);
  delay(10);

  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());


  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  /************************* DC-motors *************************/
  pinMode(MOTOR1_PIN, OUTPUT);
  pinMode(MOTOR2_PIN, OUTPUT);
  pinMode(MOTOR3_PIN, OUTPUT);

  /************************* Servos *************************/
  servoOne.attach(SERVO1_PIN);
  servoTwo.attach(SERVO2_PIN);
  servoThree.attach(SERVO3_PIN);

  /************************* Color sensor *************************/
  pinMode(KOUT_PIN, INPUT);
  pinMode(KS2_PIN, OUTPUT);
  pinMode(KS3_PIN, OUTPUT);

  /************************* Weight sensor *************************/
  pinMode(UTRIG_PIN, OUTPUT);
  pinMode(UECHO_PIN, INPUT);

}

void loop() {
  /************************* MQTT *************************/
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

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

void turnMotor(const uint8_t motorPin, const uint8_t motorRelayPin, uint8_t motorState, bool motorClockwise) {
  if (motorClockwise) {
    if (motorState == 'HIGH') {
      // Stops the motor when the motor is spinning.
      analogWrite(motorPin, 0);
      // Wait for the motor to stop.
      delay(500);
      // Switch the relay.
      digitalWrite(motorRelayPin, HIGH);
      motorClockwise = false;
      // Wait for the relay to switch.
      delay(500);
      // Spins the motor in the other direction.
      analogWrite(motorPin, getMotorVoltage());
    } else if (motorState == 'LOW') {
      digitalWrite(motorRelayPin, HIGH);
      motorClockwise = false;
      delay(500);
    }

  }
  else {
    if (motorState == 'HIGH') {
      // Stops the motor when the motor is spinning.
      analogWrite(motorPin, 0);
      // Wait for the motor to stop.
      delay(500);
      // Switch the relay.
      digitalWrite(motorRelayPin, HIGH);
      motorClockwise = true;
      // Wait for the relay to switch.
      delay(500);
      // Spins the motor in the other direction.
      analogWrite(motorPin, getMotorVoltage());

    } else if (motorState == 'LOW') {
      digitalWrite(motorRelayPin, HIGH);
      motorClockwise = true;
      delay(500);
    }
  }

}
/************************* MQTT Handlers *************************/
void callback(char* topic, byte* message, unsigned int length) {
  String messageString;
  String topicString = String(topic);

  for (int i = 0; i < length; i++) {
    Serial.print((char)message[i]);
    messageString += (char)message[i];
  }

  Serial.println();

  logFlow("Message arrived on [" + topicString + "]. Message is " + messageString);

  if (topicString == "override") {
    if (messageString == "1") {
      logFlow("WARNING: Override enabled");
      // TO DO: Add logFlow to each Serial println as above
      manualOverride = true;
    } else if (messageString == "0") {
      logFlow("WARNING: Override disabled");
      manualOverride = false;
    }
  }

  if (topicString != "override") {
    // Check if override is active
    if (manualOverride) {
      logFlow("ROUTE: From origin to manualFlow");
      manualFlow(topicString, messageString);
    } else if (topicString == "order") {
      // Incoming order example: 1200, stands for 200gr of the first kind
      String weight = messageString.substring(1);
      String siloNumber = messageString.substring(0, 1);

      // Sends order to flow
      logFlow("ROUTE: From origin to normalFlow");
      logFlow("INFO: Incoming order: " + weight + " grams of silo " + siloNumber);
      readColor();
      normalFlow(weight, siloNumber);
    } else if (topicString == "admin") {
      logFlow("ROUTE: From origin to adminFlow");
      adminFlow(messageString);
    } else {
      logFlow("ERROR: callback() :: no matching topic or override not enabled.");
    }
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("ArduinoBeanBot")) {
      Serial.println("connected");
      // Subscribe
      client.subscribe("motor1");
      client.subscribe("motor2");
      client.subscribe("motor3");
      client.subscribe("servo1");
      client.subscribe("servo2");
      client.subscribe("servo3");
      client.subscribe("order");
      client.subscribe("admin");
      client.subscribe("override");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}

/************************* Read weight sensor and publish *************************/
void readWeight() {
  String weight = "0";
  float weightInt = 0.0;

  // Initializing LCD
  LiquidCrystal lcd(LCDRS_PIN, LCDE_PIN, LCDDB4_PIN, LCDDB5_PIN, LCDDB6_PIN, LCDDB7_PIN);
  lcd.begin(16, 2); // starts connection to the LCD

  HX711_ADC LoadCell(WSDA_PIN, WSCL_PIN);
  LoadCell.begin(); // Starts  connection to the weight sensor.
  LoadCell.start(2000); // Sets the time the sensor gets to configure
  calibrateScale();
  LoadCell.setCalFactor(calibrationFactor); // Calibaration

  LoadCell.update(); // gets data from load cell
  weightInt = LoadCell.getData(); // gets output values
  weight = String(weightInt);

  // Printing the weight to the LCD screen.
  lcd.setCursor(0, 0);
  lcd.print("Weight [g]:");
  lcd.setCursor(0, 1);
  lcd.print(weight);

  // If one second has passed, weight is updated.
  if (weight != "0" && (millis() - lastReadingTimeWeight) > 1000) {
    if (orderState == 1) {
      lastReadingTimeWeight = millis();
      client.publish("firstWeightListener", weight.c_str());
    } else if (orderState == 2) {
      lastReadingTimeWeight = millis();
      client.publish("secondWeightListener", weight.c_str());
    } else {
      logFlow("ERROR: readWeight() :: orderState out of bounds.");
    }
  }
}

/************************* Read color sensor and publish *************************/
void readColor() {
  String red = "0";
  String green = "0";
  String blue = "0";

  digitalWrite(KS2_PIN, LOW);
  digitalWrite(KS3_PIN, LOW);
  red = String(pulseIn(KOUT_PIN, LOW));

  digitalWrite(KS2_PIN, LOW);
  digitalWrite(KS3_PIN, HIGH);
  blue = String(pulseIn(KOUT_PIN, LOW));

  digitalWrite(KS2_PIN, HIGH);
  digitalWrite(KS3_PIN, HIGH);
  green = String(pulseIn(KOUT_PIN, LOW));

  logFlow("Red: " + String(red) + "; green: " + String(green) + "; blue: " + String(blue) + ".");
  String color = red + green + blue;

  if (orderState == 1) {
    client.publish("firstColorListener", color.c_str());
  } else if (orderState == 2) {
    client.publish("secondColorListener", color.c_str());
  } else {
    logFlow("ERROR: readColor() :: orderState out of bounds.");
  }
}

/************************* Read ultrasonic sensor *************************/
void readUltrasonic() {
  uint8_t theta = servoOneState;
  uint16_t radius = 0;
  const uint8_t cilinderOffset = 2;
  uint8_t duration;
  uint8_t distance;

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
    logFlow("Distance to truck: " + String(distance) + "cm.");
  }

}

/************************* Program flow *************************/
void normalFlow(String weight, String siloNumber) {
  //Section 0: BAND2: Determine container location
  //Section 0: BAND1: Determine bean color
  //Section 1: BAND1: Choose silo
  //Section 2: BAND1: Lift into silo
  //Section 3: BAND1: Start rotation
  //Section 4: BAND1: Stop rotation
  //Section 5: BAND2: Set position
  //Section 6: BAND2: Start rotation
  //Section 7: BAND1: Reposition
  //Section 8: BAND2: Stop rotation
  //Section 9: BAND1: Change to other silo
  //Section 10: Repeat
  //Section X: Done
  if (orderState == 1) {
    client.publish("firstOrderListener", "done");
  } else if (orderState == 2) {
    client.publish("secondOrderListener", "done");
  } else {
    logFlow("ERROR: normalFlow() :: orderState out of bounds.");
  }

}

void manualFlow(String topic, String messageString) {
  logFlow("Changing state of [" + topic + "] to ");

  // Motors
  if (topic == "motor1") {
    if (messageString == "toggle" && motorOneState == LOW) {
      logFlow("on");
      analogWrite(MOTOR1_PIN, getMotorVoltage());
      motorOneState = HIGH;
    } else if (messageString == "toggle" && motorOneState == HIGH) {
      logFlow("off");
      analogWrite(MOTOR1_PIN, 0);
      motorOneState = LOW;
    } else if (messageString == "change_rotation") {
      turnMotor(MOTOR1_PIN, MOTOR1_RELAY_PIN, motorOneState, motorOneClockwise);
    } else {
      logFlow("ERROR: motor1 :: no message match");
    }
  } else if (topic == "motor2") {
    if (messageString == "toggle" && motorTwoState == LOW) {
      logFlow("on");
      analogWrite(MOTOR2_PIN, getMotorVoltage());
      motorTwoState = HIGH;
    } else if (messageString == "toggle" && motorTwoState == HIGH) {
      logFlow("off");
      analogWrite(MOTOR2_PIN, 0);
      motorTwoState = LOW;
    } else if (messageString == "change_rotation") {
      turnMotor(MOTOR2_PIN, MOTOR2_RELAY_PIN, motorTwoState, motorTwoClockwise);
    } else {
      logFlow("ERROR: motor2 :: no message match");
    }
  } else if (topic == "motor3") {
    if (messageString == "toggle" && motorThreeState == LOW) {
      logFlow("on");
      analogWrite(MOTOR3_PIN, getMotorVoltage());
      motorThreeState = HIGH;
    } else if (messageString == "toggle" && motorThreeState == HIGH) {
      logFlow("off");
      analogWrite(MOTOR3_PIN, 0);
      motorThreeState = LOW;
    } else if (messageString == "change_rotation") {
      turnMotor(MOTOR3_PIN, MOTOR3_RELAY_PIN, motorThreeState, motorThreeClockwise);
    } else {
      logFlow("ERROR: motor3 :: no message match");
    }
  } //Servos
  else if (topic == "servo1") {
    uint8_t angle = messageString.toInt();
    // Constrain angle between 0-180 degrees, 90 degrees is default state (silo 2)

    servoOne.write(angle);
    servoOneState = angle;
    // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

  }
  else if (topic == "servo2") {
    uint8_t angle = messageString.toInt();
    // Constrain angle between 0-180 degrees, 90 degrees is default state (silo 2)

    servoTwo.write(angle);
    servoTwoState = angle;
    // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

  }
  else  if (topic == "servo3") {
    uint8_t angle = messageString.toInt();
    // Constrain angle between 0-180 degrees, 90 degrees is default state (silo 2)

    servoThree.write(angle);
    servoThreeState = angle;
    // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

  }
  else {
    logFlow("ERROR: manualFlow() :: no topic match");
  }

}

void adminFlow(String messageString) {
  if (messageString == "reset") {
    logFlow("WARNING: Hard reset");
    resetFunc();
  } else if (messageString == "restore") {
    logFlow("WARNING: Beanbot reset");
    restoreFlow();
  } else {
    logFlow("ERROR: adminFlow() :: no message match");
  }
}

void logFlow(String message) {
  Serial.println(message);
  client.publish("logListener", message.c_str());
}

void restoreFlow() {
  // TO DO: Restore beanbot to start state.
}
