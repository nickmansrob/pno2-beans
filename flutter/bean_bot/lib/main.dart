import 'package:bean_bot/providers/color_calibration_state.dart';
import 'package:bean_bot/providers/order_state.dart';
import 'package:bean_bot/pages/color_calibration.dart';
import 'package:bean_bot/pages/debug.dart';
import 'package:bean_bot/pages/homepage.dart';
import 'package:bean_bot/pages/logs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/mqtt_app_state.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'The Bean Bot',
      // Creates the providers states for the connection state and the weight state.
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<MQTTAppState>(
            create: (_) => MQTTAppState(),
          ),
          ChangeNotifierProvider<OrderState>(
            create: (_) => OrderState(),
          ),
          ChangeNotifierProvider<ColorCalibrationState>(
            create: (_) => ColorCalibrationState(),
          ),
        ],
        child: const BeanBot(),
      ),
    ),
  );
}

class BeanBot extends StatefulWidget {
  const BeanBot({Key? key}) : super(key: key);

  @override
  _BeanBotState createState() => _BeanBotState();
}

class _BeanBotState extends State<BeanBot> {
  @override
  // Widget that creates the routs between the different pages.
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/debug': (context) => const DebugPage(),
        '/logs': (context) => const LogPage(),
        '/color_calibration': (context) => const ColorCalibrationPage(),
      },
    );
  }
}
