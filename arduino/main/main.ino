/************************* Libraries *************************/
// #include <WiFi.h>
// #include <Arduino.h>
#include <ESP8266WiFi.h>
#include <Servo.h>
#include <PubSubClient.h>

/************************* WiFi *************************/

const char* ssid = "ENVYROB113004";
const char* password = "0j085693";
const char* mqtt_server = "192.168.137.1";

/************************* Servos *************************/
Servo siloSelect;
const uint8_t SILO_PIN_NUMBER = 9;
int siloSelectPos = 0;

Servo angleSelect;
const uint8_t ANGLE_PIN_NUMBER = 8;
int angleSelectPos = 0;

/************************* MQTT *************************/
WiFiClient espClient;
PubSubClient client(espClient);
long lastMsg = 0;
char msg[50];
int value = 0;

byte motorState = LOW;


void setup() {
  /************************* Initializaton *************************/
  Serial.begin(115200);
  delay(10);
  // We start by connecting to a WiFi network
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
  
  /************************* Servos *************************/
  siloSelect.attach(SILO_PIN_NUMBER);
  angleSelect.attach(ANGLE_PIN_NUMBER);

}

void loop() {
  /************************* MQTT *************************/
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

}

/************************* MQTT Handlers *************************/
void callback(char* topic, byte* message, unsigned int length) {
  Serial.print("Message arrived on topic: ");
  Serial.print(topic);
  Serial.print(". Message: ");
  String messageTemp;
  
  for (int i = 0; i < length; i++) {
    Serial.print((char)message[i]);
    messageTemp += (char)message[i];
  }
  Serial.println();

  // Feel free to add more if statements to control more GPIOs with MQTT

  // If a message is received on the topic esp32/output, you check if the message is either "on" or "off". 
  // Changes the output state according to the message
  if (String(topic) == "motor1") {
    Serial.print("Changing output to ");
    if(messageTemp == "toggle" && motorState == LOW){
      Serial.println("on");
      digitalWrite(5, HIGH);
      motorState = HIGH;
    }
    else if(messageTemp == "toggle" && motorState == HIGH){
      Serial.println("off");
      digitalWrite(5, LOW);
      motorState == LOW;
    }
  }
}

void reconnect() {
  // Loop until we're reconnected
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Attempt to connect
    if (client.connect("BeanBotArduino")) {
      Serial.println("connected");
      // Subscribe
      client.subscribe("motor1");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      // Wait 5 seconds before retrying
      delay(5000);
    }
  }
}
