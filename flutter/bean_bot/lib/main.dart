import 'package:bean_bot/Providers/weight_input_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bean_bot/Pages/logs.dart';
import 'package:bean_bot/Pages/debug.dart';
import 'Providers/MQTTAppState.dart';
import 'package:bean_bot/Pages/homepage.dart';

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
          ChangeNotifierProvider<WeightInputState>(
            create: (_) => WeightInputState(),
          )
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
      },
    );
  }
}
