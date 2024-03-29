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
      manualOverride = true;
      wireFlow("debug_1");
    } else if (messageString == "0") {
      logFlow("WARNING: Override disabled");
      manualOverride = false;
      wireFlow("debug_0");
    }
  }

  if (topicString != "override") {
    // Check if override is active
    if (manualOverride) {
      logFlow("ROUTE: From origin to manualFlow");
      manualFlow(topicString, messageString);
    }  else if ((topicString == "order1") || (topicString == "order2") && messageString != "0000") {
      logFlow("ROUTE: From origin to normalFlow");
      normalFlow(topicString, messageString);
    } else if (topicString == "stop") {
      stopFlow();
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
    if (client.connect("ArduinoBeanBotNodeMCU")) {
      Serial.println("connected");
      // Subscribe
      client.subscribe("motor1");
      client.subscribe("motor2");

      client.subscribe("servo1");
      client.subscribe("servo2");
      client.subscribe("servo3");
      client.subscribe("servo4");

      client.subscribe("order1");
      client.subscribe("order2");

      client.subscribe("weight1");
      client.subscribe("weight2");

      client.subscribe("weightControl");
      client.subscribe("weightData");

      client.subscribe("colorControl");
      client.subscribe("colorData");

      client.subscribe("distControl");

      client.subscribe("override");
      client.subscribe("colorCal");

      client.subscribe("rgb");

      client.subscribe("stop");

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
  }

  else if (topic == "motor2") {
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
  }

  else if (topic == "servo2") {
    wireFlow("servo2_" + messageString);
  }

  else if (topic == "servo3") {
    wireFlow("servo3_" + messageString);
  }

  else if (topic == "servo4") {
    wireFlow("servo4_" + messageString);
  }

  else if (topic == "weight1") {
    logFlow("ROUTE: From origin to weight1");
    wireFlow("weight1_" + messageString);
  }

  else if (topic == "weight2") {
    logFlow("ROUTE: From origin to weight2");
    wireFlow("weight2_" + messageString);
  }

  else if (topic == "distControl") {
    logFlow("ROUTE: From origin to distControl");
    wireFlow("distControl_" + messageString);
  }

  else if (topic == "colorControl") {
    logFlow("ROUTE: From origin to colorControl");
    wireFlow("colorControl_" + messageString);
  }

  else if (topic == "weightControl" ) {
    logFlow("ROUTE: From origin to weightControl" );
    wireFlow("weightControl_" + messageString);
  }

  else if (topic == "colorCal") {
    logFlow("ROUTE: From origin to colorCal");
    wireFlow("colorCal_" + messageString);
  }

  else if (topic == "rgb") {
    logFlow("ROUTE: From origin to rgb");
    wireFlow("rgb_" + messageString);
  }
  else {
    logFlow("ERROR: manualFlow() :: no topic match");
  }
}

void normalFlow(String orderNumber, String messageString) {
  Serial.println(orderNumber);
  wireFlow(orderNumber + "_" + messageString);
}

void stopFlow() {
  logFlow("ROUTE: From origin to stop");
  wireFlow("stop_stop");
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
    Serial.println(topic);
    Serial.println(messageString);
  }

  if (message != "" && messageString != "") {
    logFlow(messageString);
    if (topic == "colorData")  {
      client.publish("colorData", messageString.c_str());
    }
    else if (topic == "distData") {
      client.publish("distData", messageString.c_str());
    }
    else if (topic == "weightData" ) {
      client.publish("weightData", messageString.c_str());
    }
    else if (topic == "colorCal") {
      client.publish("colorCal", messageString.c_str());
    }
  }
}

void wireFlow(String message) {
  Wire.beginTransmission(8);
  Wire.write(message.c_str());
  Wire.endTransmission();
}
