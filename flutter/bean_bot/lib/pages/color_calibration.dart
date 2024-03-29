import 'package:bean_bot/data/menu_items_color.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:bean_bot/providers/color_calibration_state.dart';
import 'package:bean_bot/providers/mqtt_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ColorCalibrationPage extends StatefulWidget {
  const ColorCalibrationPage({Key? key}) : super(key: key);

  @override
  _ColorCalibrationPageState createState() => _ColorCalibrationPageState();
}

class _ColorCalibrationPageState extends State<ColorCalibrationPage> {
  /////////////////////////// Variables ///////////////////////////
  bool calibrationState = false;

  /////////////////////////// Widgets ///////////////////////////
  @override
  // Builds the main widget of the Color Calibration Page.
  Widget build(BuildContext context) {
    final MQTTAppState currentAppState =
        Provider.of<MQTTAppState>(context, listen: false);
    ColorCalibrationState colorCalibrationState =
        Provider.of<ColorCalibrationState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(calibrationTitleText(colorCalibrationState)),
        actions: <Widget>[
          PopupMenuButton<MenuItem>(
            onSelected: (item) => onSelected(context, item),
            itemBuilder: (context) =>
                [...MenuItems.items.map(buildItem).toList()],
          ),
        ],
      ),
      body: ListView(
        children: [
          if (!(calibrationState))
            _buildConnectionStateText(
              setMessageStatusBar(
                  Provider.of<MQTTAppState>(context).getAppConnectionState),
              setColorStatusBar(
                  Provider.of<MQTTAppState>(context).getAppConnectionState),
            ),
          if (!(calibrationState))
            _buildStartCalibrationButton(context, currentAppState,
                currentAppState.getAppConnectionState, colorCalibrationState),
          if (calibrationState) _buildColorContainer(colorCalibrationState),
        ],
      ),
    );
  }

  // Creates the connection state widget on top of the screen.
  Widget _buildConnectionStateText(String status, Color color) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: color,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(status, textAlign: TextAlign.center),
              )),
        ),
      ],
    );
  }

  // Builds the button for starting the calibration.
  Widget _buildStartCalibrationButton(
      BuildContext context,
      MQTTAppState appState,
      MQTTAppConnectionState connectionState,
      ColorCalibrationState colorCalibrationState) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: disableTextFields(appState.getAppConnectionState)
                  ? () {
                      colorChanges(appState, colorCalibrationState);
                    }
                  : null,
              child: const Text('Start calibration'),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: disableTextFields(appState.getAppConnectionState)
                  ? () {
                resetCalibration(colorCalibrationState);
              }
                  : null,
              child: const Text('Reset calibration'),
            ),
          ),
        ),
      ],
    );
  }

  // Builds a full-screen container which changes colors for calibrating.
  Widget _buildColorContainer(ColorCalibrationState colorCalibrationState) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ColorCalibrationState colorCalibrationState =
        Provider.of<ColorCalibrationState>(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Color.fromRGBO(colorCalibrationState.getR,
            colorCalibrationState.getG, colorCalibrationState.getB, 1.0),
      ),
    );
  }

  /////////////////////////// Helper functions ///////////////////////////
  // Gets the message for the status bar on top of the screen.
  String setMessageStatusBar(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  // Gets the color of the status bar on top of the screen.
  Color setColorStatusBar(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return Colors.green;
      case MQTTAppConnectionState.connecting:
        return Colors.deepOrange;
      case MQTTAppConnectionState.disconnected:
        return Colors.red;
    }
  }

  // Disables the buttons and text-fields when not connected to the broker.
  bool disableTextFields(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

  // Function for setting the `calibrationState`.
  Future<void> colorChanges(MQTTAppState appState,
      ColorCalibrationState colorCalibrationState) async {
    VoidCallback? callBack() {
      Future.delayed(Duration.zero, () {
        setState(() {
          calibrationState = true;
        });
      });
      return null;
    }

    // This functions loops over all the possible RGB colors, with increments of size n.
    // The plan is to synchronize the data via MQTT. When the user presses the button to start the calibration, the app sends 'start_calibration' via MQTT, then it listens for the Arduino to react. When connection is established, the app sends 'startRRRGGGBBB'. When the Arduino receives this code, it conduct three measurements and then sends 'stopRRRGGGBBB'. The then increases the counter and starts the process again.
    int increment = 51;
    _publishMessage('calApp', 'colorCal');

    while (!(colorCalibrationState.getStartCalibration)) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    if (colorCalibrationState.getStartCalibration) {
      callBack();
      // Estimated time of completion: 3375 seconds.
      _publishMessage(
          colorCalibrationState.getCalibrationSentMessage, 'colorCal');
      while (toIncrementRGB(colorCalibrationState)) {
        if (colorCalibrationState.getCalibrationReceivedMessage.substring(4) ==
            colorCalibrationState.getCalibrationSentMessage.substring(5)) {
          incrementRGB(colorCalibrationState, increment);
        } else {
          await Future.delayed(const Duration(milliseconds: 10));
        }
      }
    }
    calibrationState = false;
  }

  // Function that checks if the RGB value has to be increased.
  bool toIncrementRGB(ColorCalibrationState colorCalibrationState) {
    int R = colorCalibrationState.getR;
    int G = colorCalibrationState.getG;
    int B = colorCalibrationState.getB;

    // When the RGB value equals (255, 255, 255), the maximum has been reached.
    if (R == 255 && G == 255 && B == 255) {
      return false;
    } else {
      return true;
    }
  }

  // Function for dynamically setting the title text of the page.
  String calibrationTitleText(ColorCalibrationState colorCalibrationState) {
    if (calibrationState) {
      return "Calibrating... (${colorCalibrationState.getCalibrationsDone}/125)";
    } else {
      return "Color Calibration";
    }
  }

  // Function for making message that has to be sent via MQTT.
  String makeMessage(ColorCalibrationState colorCalibrationState) {
    String r = colorCalibrationState.getR.toString();
    String g = colorCalibrationState.getG.toString();
    String b = colorCalibrationState.getB.toString();
    if (r.length < 3 || g.length < 3 || b.length < 3) {
      while (r.length != 3) {
        r = '0' + r;
      }
      while (g.length != 3) {
        g = '0' + g;
      }
      while (b.length != 3) {
        b = '0' + b;
      }
    }
    colorCalibrationState.setCalibrationSentMessage('start' + r + g + b);
    return 'start' + r + g + b;
  }

  // Creates the navigation menu.
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Text(item.text),
      );

  /////////////////////////// Voids ///////////////////////////
  // For sending messages via MQTT.
  void _publishMessage(String text, String topic) {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);

    MQTTManager manager = appState.getMQTTManager;
    manager.publish(text, topic);
  }

  // Void that handles the increment of the color of the main container.
  void incrementRGB(
      ColorCalibrationState colorCalibrationState, int increment) {
    int R = colorCalibrationState.getR;
    int G = colorCalibrationState.getG;
    int B = colorCalibrationState.getB;

    if (B == 255 && G == 255) {
      colorCalibrationState.setB(0);
      colorCalibrationState.setG(0);
      colorCalibrationState.setR(R + increment);
    } else if (B == 255 && G != 255) {
      colorCalibrationState.setB(0);
      colorCalibrationState.setG(G + increment);
    } else {
      colorCalibrationState.setB(B + increment);
    }
    _publishMessage(makeMessage(colorCalibrationState), 'colorCal');
    colorCalibrationState.incrementCalibrationsDone();
  }

  void resetCalibration(ColorCalibrationState colorCalibrationState) {
    colorCalibrationState.setStartCalibration(false);
    colorCalibrationState.setR(0);
    colorCalibrationState.setG(0);
    colorCalibrationState.setB(0);
    colorCalibrationState.resetCalibrationsDone();
    colorCalibrationState.setCalibrationReceivedMessage('stop256256256');
    colorCalibrationState.setCalibrationSentMessage('start000000000');
  }

  // Handles the navigation of the popupmenu.
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemDebug:
        Navigator.popAndPushNamed(context, '/debug');
        break;
      case MenuItems.itemLog:
        Navigator.popAndPushNamed(context, '/logs');
        break;
    }
  }
}
