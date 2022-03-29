/************************* Libraries *************************/
#if defined(_AVR_)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

#include <Wire.h>
#include <PubSubClient.h>

/************************* WiFi *************************/
const char * ssid = "ENVYROB113004";
const char * password = "0j085693";
const char * mqtt_server = "192.168.137.1";

/************************* MQTT *************************/
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

bool manualOverride = false;

void (* resetFunc) (void) = 0;

String incomingSerial;
char rdata;

void setup() {
  /************************* Initializaton *************************/
  Serial.begin(115200);
  Wire.begin(5, 4);
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

}

void loop() {
  /************************* MQTT *************************/
  if (!client.connected()) {
    reconnect();
  }
  client.loop();
  pollWire();
  delay(100);

}

/************************* MQTT Handlers *************************/
void callback(char* topic, byte* message, unsigned int length) {
  String messageString;
  String topicString = String(topic);

  for (int i = 0; i < length; i++) {
    messageString += (char)message[i];
  }

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
      // manualFlow(topicString, messageString);
    } else if (topicString == "adminListener") {
      logFlow("ROUTE: From origin to adminFlow");
      adminFlow(messageString);
    } else if (topicString == "firstWeightListener") {
      logFlow("ROUTE: From origin to weightFlow");
      wireFlow("weight1_" + messageString);
    } else if (topicString == "secondWeightListener") {
      logFlow("ROUTE: From origin to weightFlow");
      wireFlow("weight2_" + messageString);
    } else if (topicString == "readUltrasonic") {
      logFlow("ROUTE: From origin to ultranosicFlow");
      wireFlow("ultra_" + messageString);
      Serial.println(messageString);

    } else if (topicString == "readColor") {
      logFlow("ROUTE: From origin to colorFlow");
      Serial.println(messageString);
      wireFlow("color_" + messageString);
    }
    else {
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
      client.subscribe("servo1");
      client.subscribe("servo2");
      client.subscribe("servo3");
      client.subscribe("servo4");
      client.subscribe("order");
      client.subscribe("adminListener");
      client.subscribe("firstWeightListener");
      client.subscribe("secondWeightListener");
      client.subscribe("readUltrasonic");
      client.subscribe("readColor");
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

/************************* Program flow *************************/
void manualFlow(String topic, String messageString) {
  logFlow("Changing state of [" + topic + "] to ");

  // Motors
  if (topic == "motor1") {
    if (messageString == "toggle") {
      wireFlow("motor1_toggle");
    } else if (messageString == "change_rotation") {
      wireFlow("motor1_turn");
    } else {
      logFlow("ERROR: motor1 :: no message match");
    }
  } else if (topic == "motor2") {
    if (messageString == "toggle") {
      wireFlow("motor2_toggle");
    } else if (messageString == "change_rotation") {
      wireFlow("motor2_turn");
    } else {
      logFlow("ERROR: motor2 :: no message match");
    }
  }
  //Servos
  else if (topic == "servo1") {
    wireFlow("servo1_" + messageString);

  } else if (topic == "servo2") {
    wireFlow("servo2_" + messageString);

  } else if (topic == "servo3") {
    wireFlow("servo3_" + messageString);

  } else if (topic == "servo4") {
    wireFlow("servo4_" + messageString);
  }
  else {
    logFlow("ERROR: manualFlow() :: no topic match");
  }
}

void adminFlow(String messageString) {
  if (messageString == "reset") {
    logFlow("WARNING: Hard reset");
    wireFlow("admin_reset");
    resetFunc();
  } else if (messageString == "restore") {
    logFlow("WARNING: Beanbot restore");
    wireFlow("admin_restore");
  } else {
    logFlow("ERROR: adminFlow() :: no message match");
  }
}

void logFlow(String message) {
  Serial.println(message);
  client.publish("logListener", message.c_str());
}

void pollWire() {
  String message = "";
  String topic = "";
  String messageString = "";

  Wire.requestFrom(8, 32);
  while (Wire.available()) {
    char c = Wire.read();
    message = message + c;

  }

  while (message.indexOf("@") != -1) {
    int questionmarkIndex = message.indexOf("@");
    message.remove(questionmarkIndex, 1);
  }

  int indexDelimiter = message.indexOf('_');

  if (indexDelimiter == -1) {
    // logFlow(message);
  }
  else {
    topic = message.substring(0, indexDelimiter);
    messageString = message.substring(indexDelimiter + 1, message.length());
  }

  if (message != "" and messageString != "") {
    logFlow(messageString);
  }
}

void wireFlow(String message) {
  Wire.beginTransmission(8);
  Wire.write(message.c_str());
  Wire.endTransmission();
}
