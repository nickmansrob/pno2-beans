/************************* Libraries *************************/
#if defined(__AVR__)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

#include <Servo.h>

#include <PubSubClient.h>

/************************* WiFi *************************/

const char * ssid = "ENVYROB113004";
const char * password = "0j085693";
const char * mqtt_server = "192.168.137.1";

/************************* DC-motors *************************/
const uint8_t MOTOR_VOLTAGE = 2;

const uint8_t MOTOR1_PIN = 5;
byte motorOneState = LOW;

const uint8_t MOTOR2_PIN = 5;
byte motorTwoState = LOW;

const uint8_t MOTOR3_PIN = 5;
byte motorThreeState = LOW;

const uint8_t MOTOR4_PIN = 5;
byte motorFourState = LOW;

const uint8_t MOTOR5_PIN = 5;
byte motorFiveState = LOW;

/************************* Servos *************************/
Servo servoOne;
const uint8_t SERVO1_PIN = 9;
int servoOneState = 90;

/************************* MQTT *************************/
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

bool manualOverride = false;

/************************* Reset function *************************/
void(* resetFunc) (void) = 0;


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

  /************************* Servos *************************/
  //servoOne.attach(SERVO1_PIN);

}

void loop() {
  /************************* MQTT *************************/
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

}

/************************* Helpers *************************/
int getMotorVoltage() {
  return map(MOTOR_VOLTAGE, 0, 5, 0, 255);
}

/************************* MQTT Handlers *************************/
void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
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
      String beanKind = messageString.substring(0, 1);

      // Sends order to flow
      logFlow("ROUTE: From origin to normalFlow");
      logFlow("INFO: Incoming order: " + weight + " grams of kind " + beanKind);
      normalFlow(weight, beanKind);
    } else if (topicString == "admin") {
      logFlow("ROUTE: From origin to adminFlow");
      adminFlow(messageString);
    } else {
      logFlow("ERROR: No matching topic or override not enabled.");
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
      client.subscribe("motor4");
      client.subscribe("motor5");
      client.subscribe("order");
      client.subscribe("servo1");
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
  // TO DO: Implement sensor readings

  if (weight != "0") {
    client.publish("weightListener", weight.c_str());
  }
  // TO DO: Implement timer to avoid flooding the topic. Weight should be updated once a second. Use millis() function.
}

/************************* Program flow *************************/
void normalFlow(String weight, String beanKind) {
  //Section 0: Determine container location
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
}

void manualFlow(String topic, String messageString) {
  logFlow("Changing state of [" + topic + "] to ");

  // Motor 1
  if (topic == "motor1") {
    if (messageString == "toggle" && motorOneState == LOW) {
      logFlow("on");
      digitalWrite(MOTOR1_PIN, HIGH);
      // TO DO: If needed implement analogWrite to adjust PWM
      motorOneState = HIGH;
    } else if (messageString == "toggle" && motorOneState == HIGH) {
      logFlow("off");
      digitalWrite(MOTOR1_PIN, LOW);
      motorOneState = LOW;
    } else {
      logFlow("ERROR: Unspecified state");
    }
  }

  //Servo 1
  if (topic == "servo1") {
    int angle = messageString.toInt();

    // Constrain angle between 90+-45, 90 degrees is default state (silo 2)

    if (-180 <= angle && angle <= 180) {
      // Angle is valid, proceed

      // TO DO: Implement checking where the servo is located, then constrain angle again to prevent the servo from rotating to far

      servoOne.write(angle);
      servoOneState = angle;

      // TO DO: Implement feedback from Servo to correct angle, don't adjust servoState accordingly!!

    } else {
      logFlow("ERROR: Angle out of bounds");
    }
  }
}

void adminFlow(String messageString) {
  if (messageString == "reset") {
    logFlow("WARNING: Hard reset");
    resetFunc();
  } else {
    logFlow("ERROR: Unspecified state");
  }
}

void logFlow(String message) {
  Serial.println(message);
  client.publish("logListener", message.c_str());
}
