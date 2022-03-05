/************************* Libraries *************************/
// #include <WiFi.h>
// #include <Arduino.h>
#include <ESP8266WiFi.h>

#include <Servo.h>

#include <PubSubClient.h>

/************************* WiFi *************************/

const char * ssid = "ENVYROB113004";
const char * password = "0j085693";
const char * mqtt_server = "192.168.137.1";

/************************* DC-motors *************************/
const uint8_t MOTOR1_PIN = 5;
byte motorOneState = LOW;

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
  //siloSelect.attach(SILO_PIN_NUMBER);
  //angleSelect.attach(ANGLE_PIN_NUMBER);

}

void loop() {
  /************************* MQTT *************************/
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  readWeight();

}

/************************* MQTT Handlers *************************/
void callback(char * topic, byte * message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(String(topic));
  Serial.print(". Message: ");
  String messageString;

  for (int i = 0; i < length; i++) {
    Serial.print((char) message[i]);
    messageString += (char) message[i];
  }
  Serial.println();

  logFlow("Arduino received message " + messageString + " on topic " + String(topic));

  if (String(topic) == "override") {
    Serial.println("In override if");
    if (messageString == "1") {
      Serial.println("WARNING: Override enabled");
      // TO DO: Add logFlow to each Serial println as above
      manualOverride = true;
    } else if (messageString == "0") {
      Serial.println("WARNING: Override disabled");
      manualOverride = false;
    }
  }

  // Check if override is active
  if (manualOverride) {
    Serial.println("ROUTE: From origin to manualFlow");
    manualFlow(String(topic), messageString);
  } else if (String(topic) == "order") {
    // Incoming order example: 1200, stands for 200gr of the first kind
    String weight = messageString.substring(1);
    String beanKind = messageString.substring(0, 1);

    // Sends order to flow
    Serial.println("ROUTE: From origin to normalFlow");
    Serial.println("INFO: Incoming order: " + weight + " grams of kind " + beanKind);
    normalFlow(weight, beanKind);
  } else if (String(topic) == "admin") {
    Serial.println("ROUTE: From origin to adminFlow");
    adminFlow(messageString);
  } else {
    Serial.println("ERROR: no matching topic.");
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
    client.publish("weightListener", convertToChar(weight));
  }
  // TO DO: Implement timer to avoid flooding the topic. Weight should be updated once a second. Use millis() function.
}

/************************* String to char converter *************************/

char* convertToChar(String message) {
  // Calculate char buffer length
  int bufferLength = message.length() + 1; // Reserve one extra byte for null terminator (0x00)
  // Prepare char buffer
  char serialChar[bufferLength];
  // Cast String to char
  message.toCharArray(serialChar, bufferLength);

  return serialChar;
}

/************************* Program flow *************************/
void normalFlow(String weight, String beanKind) {
  // TO DO: Code needed for a normal program flow.
}

void manualFlow(String topic, String messageString) {
  Serial.print("Changing state of [" + topic + "] to ");

  // Motor 1
  if (topic == "motor1") {
    if (messageString == "toggle" && motorOneState == LOW) {
      Serial.println("on");
      digitalWrite(MOTOR1_PIN, HIGH);
      // TO DO: If needed implement analogWrite to adjust PWM
      motorOneState = HIGH;
    } else if (messageString == "toggle" && motorOneState == HIGH) {
      Serial.println("off");
      digitalWrite(MOTOR1_PIN, LOW);
      motorOneState = LOW;
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

    }
  }
}

void adminFlow(String messageString) {
  if (messageString == "reset") {
    Serial.println("WARNING: Hard reset");
    resetFunc();
  }

  if (messageString == "reconnect") {
    Serial.println("WARNING: MQTT Reconnect");
    client.disconnect();
    reconnect();
  }

  if (messageString == "printip") {
    Serial.println("INFO: Printing broker IP: " + String(mqtt_server));
    client.publish("ipListener", mqtt_server);
  }
}

void logFlow(String message) {
  client.publish("logListener", convertToChar(message));

  // TO DO: Move Serial.println to this method for a cleaner code and less duplication
}
