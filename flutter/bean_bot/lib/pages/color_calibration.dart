import 'package:flutter/material.dart';
import 'package:bean_bot/Providers/mqtt_app_state.dart';
import 'package:provider/provider.dart';
import 'package:bean_bot/Providers/color_calibration_state.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';
import 'package:bean_bot/data/menu_items_color.dart';
import 'package:bean_bot/model/menu_item.dart';

class ColorCalibrationPage extends StatefulWidget {
  const ColorCalibrationPage({Key? key}) : super(key: key);

  @override
  _ColorCalibrationPageState createState() => _ColorCalibrationPageState();
}

class _ColorCalibrationPageState extends State<ColorCalibrationPage> {
  bool calibrationState = false;

  @override
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
              _prepareStateMessageFrom(
                  Provider.of<MQTTAppState>(context).getAppConnectionState),
              setColor(
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

  String _prepareStateMessageFrom(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return 'Connected';
      case MQTTAppConnectionState.connecting:
        return 'Connecting';
      case MQTTAppConnectionState.disconnected:
        return 'Disconnected';
    }
  }

  Color setColor(MQTTAppConnectionState state) {
    switch (state) {
      case MQTTAppConnectionState.connected:
        return Colors.green;
      case MQTTAppConnectionState.connecting:
        return Colors.deepOrange;
      case MQTTAppConnectionState.disconnected:
        return Colors.red;
    }
  }

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
              onPressed: disableTextField(appState.getAppConnectionState)
                  ? () {
                      colorChanges(appState, colorCalibrationState);
                    }
                  : null,
              child: const Text('Start calibration'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorContainer(ColorCalibrationState colorCalibrationState) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    ColorCalibrationState colorCalibrationState =
        Provider.of<ColorCalibrationState>(context);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Color.fromRGBO(colorCalibrationState.get_r,
            colorCalibrationState.get_g, colorCalibrationState.get_b, 1.0),
      ),
    );
  }

  bool disableTextField(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

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
    int increment = 17;
    _publishMessage('start_calibration_app', 'colorCalibration');

    while (!(colorCalibrationState.getStartCalibration)) {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    if (colorCalibrationState.getStartCalibration) {
      callBack();
      // Estimated time of completion: 3375 seconds.
      _publishMessage(
          colorCalibrationState.getCalibrationSentMessage, 'colorCalibration');
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

  bool toIncrementRGB(ColorCalibrationState colorCalibrationState) {
    int R = colorCalibrationState.get_r;
    int G = colorCalibrationState.get_g;
    int B = colorCalibrationState.get_b;

    if (R == 155 && G == 155 && B == 155) {
      return false;
    } else {
      return true;
    }
  }

  void incrementRGB(
      ColorCalibrationState colorCalibrationState, int increment) {
    int R = colorCalibrationState.get_r;
    int G = colorCalibrationState.get_g;
    int B = colorCalibrationState.get_b;

    if (B == 255 && G == 255) {
      colorCalibrationState.set_b(0);
      colorCalibrationState.set_g(0);
      colorCalibrationState.set_r(R + increment);
    } else if (B == 255 && G != 255) {
      colorCalibrationState.set_b(0);
      colorCalibrationState.set_g(G + increment);
    } else {
      colorCalibrationState.set_b(B + increment);
    }
    _publishMessage(makeMessage(colorCalibrationState), 'colorCalibration');
    colorCalibrationState.incrementCalibrationsDone();
  }

  String calibrationTitleText(ColorCalibrationState colorCalibrationState) {
    if (calibrationState) {
      return "Calibrating... (${colorCalibrationState.getCalibrationsDone}/3375)";
    } else {
      return "Color Calibration";
    }
  }

  String makeMessage(ColorCalibrationState colorCalibrationState) {
    String r = colorCalibrationState.get_r.toString();
    String g = colorCalibrationState.get_g.toString();
    String b = colorCalibrationState.get_b.toString();
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

  void _publishMessage(String text, String topic) {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);

    MQTTManager manager = appState.getMQTTManager;
    manager.publish(text, topic);
  }

//// Navigation Menu ////
// Handles the navigation of the popupmenu.
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemDebug:
        Navigator.popAndPushNamed(context, '/debug');
        break;
      case MenuItems.itemLog:
        Navigator.popAndPushNamed(context, '/color_calibration');
        break;
    }
  }

// Creates the navigation menu.
  PopupMenuItem<MenuItem> buildItem(MenuItem item) => PopupMenuItem(
        value: item,
        child: Text(item.text),
      );
}
