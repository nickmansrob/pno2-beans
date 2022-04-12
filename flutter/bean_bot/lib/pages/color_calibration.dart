import 'package:flutter/material.dart';
import 'package:bean_bot/Providers/mqtt_app_state.dart';
import 'package:provider/provider.dart';
import 'package:bean_bot/Providers/color_calibration_state.dart';
import 'package:bean_bot/mqtt/mqtt_manager.dart';


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

  @override
  void initState() {
    super.initState();
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
              onPressed: disableTextField(appState.getAppConnectionState)? () {
                setState(() {
                  calibrationState = true;
                });
                colorChanges(appState, colorCalibrationState);
              }: null,
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

  Future<void> colorChanges(MQTTAppState appState,ColorCalibrationState colorCalibrationState) async {
    // This functions loops over all the possible RGB colors, with increments of size n.
    int increment = 17;

    // Estimated time of completion: 3375 seconds.
    while (colorCalibrationState.get_r < 255) {
      while (colorCalibrationState.get_g < 255) {
        while (colorCalibrationState.get_b < 255) {
          colorCalibrationState.set_b(colorCalibrationState.get_b + increment);
          colorCalibrationState.incrementCalibrationsDone();
          _publishMessage(makeMessage(colorCalibrationState), 'colorCalibration');
          print('R' + colorCalibrationState.get_r.toString());
          print('R' + colorCalibrationState.get_g.toString());
          print('R' + colorCalibrationState.get_b.toString());

          await Future.delayed(const Duration(seconds: 1));
        }
        colorCalibrationState.set_b(0);
        colorCalibrationState.set_g(colorCalibrationState.get_g + increment);
        colorCalibrationState.incrementCalibrationsDone();
        _publishMessage(makeMessage(colorCalibrationState), 'colorCalibration');
        await Future.delayed(const Duration(seconds: 1));
      }
      colorCalibrationState.set_g(0);
      colorCalibrationState.set_b(0);
      colorCalibrationState.set_r(colorCalibrationState.get_r + increment);
      colorCalibrationState.incrementCalibrationsDone();
      _publishMessage(makeMessage(colorCalibrationState), 'colorCalibration');
      await Future.delayed(const Duration(seconds: 1));
    }
    calibrationState = false;
  }

  String calibrationTitleText(ColorCalibrationState colorCalibrationState) {
    if(calibrationState) {
      return "Calibrating... (${colorCalibrationState.getCalibrationsDone}/3375)";
    }
    else {
      return "Color Calibration";
    }
  }

  String makeMessage(ColorCalibrationState colorCalibrationState) {
    String r = colorCalibrationState.get_r.toString();
    String g = colorCalibrationState.get_g.toString();
    String b = colorCalibrationState.get_b.toString();
    if (r.length < 3  || g.length < 3 || b.length < 3) {
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
    return r + g + b;
  }

  void _publishMessage(String text, String topic) {
    final MQTTAppState appState =
    Provider.of<MQTTAppState>(context, listen: false);

    MQTTManager manager = appState.getMQTTManager;
    manager.publish(text, topic);
  }
}
