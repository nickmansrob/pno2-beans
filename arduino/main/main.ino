/************************* Libraries *************************/
#include <WiFi.h>
#include <Arduino.h>
//#include <ESP8266WiFi.h>
#include <Servo.h>
#include <WebSocketsServer.h>

/************************* Definitions *************************/

#define WLAN_SSID "BeanBot312"
#define WLAN_PASS "464UAvp6UR5q"

/************************* Servos *************************/
Servo siloSelect;
const uint8_t SILO_PIN_NUMBER = 9;
int siloSelectPos = 0;

Servo angleSelect;
const uint8_t ANGLE_PIN_NUMBER = 8;
int angleSelectPos = 0;

/************************* Websocket *************************/
WebSocketsServer webSocket = WebSocketsServer(1337);

char msg_buf[10];
int led_state = 0;
int led_pin = 0;

// Callback: receiving any WebSocket message
void onWebSocketEvent(uint8_t client_num,
                      WStype_t type,
                      uint8_t * payload,
                      size_t length) {

  // Figure out the type of WebSocket event
  switch(type) {

    // Client has disconnected
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", client_num);
      break;

    // New client has connected
    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(client_num);
        Serial.printf("[%u] Connection from ", client_num);
        Serial.println(ip.toString());
      }
      break;

    // Handle text messages from client
    case WStype_TEXT:

      // Print out raw message
      Serial.printf("[%u] Received text: %s\n", client_num, payload);

      // Toggle LED
      if ( strcmp((char *)payload, "toggleLED") == 0 ) {
        led_state = led_state ? 0 : 1;
        Serial.printf("Toggling LED to %u\n", led_state);
        digitalWrite(led_pin, led_state);

      // Report the state of the LED
      } else if ( strcmp((char *)payload, "getLEDState") == 0 ) {
        sprintf(msg_buf, "%d", led_state);
        Serial.printf("Sending to [%u]: %s\n", client_num, msg_buf);
        webSocket.sendTXT(client_num, msg_buf);

      // Message not recognized
      } else {
        Serial.println("[%u] Message not recognized");
      }
      break;
      
    default:
      break;
  }
}


void setup() {
  /************************* Initializaton *************************/
  Serial.begin(115200);
  delay(10);

  // Create WiFi access point.
  IPAddress apIP(192, 168, 0, 1);   //Static IP for wifi gateway
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); //set Static IP gateway
  
  Serial.print("Creating WiFi network ");
  Serial.println(WLAN_SSID);

  WiFi.softAP(WLAN_SSID, WLAN_PASS);

  delay(1000);

  Serial.println("WiFi created.");
  Serial.println("IP address: "); 
  Serial.println(WiFi.softAPIP());

  // Start WebSocket server and assign callback
  webSocket.begin();
  webSocket.onEvent(onWebSocketEvent);
  Serial.println("Websocket started.");
  
  /************************* Servos *************************/
  siloSelect.attach(SILO_PIN_NUMBER);
  angleSelect.attach(ANGLE_PIN_NUMBER);

}

void loop() {
  /************************* Websocket *************************/
  webSocket.loop(); //keep this line on loop method

}
