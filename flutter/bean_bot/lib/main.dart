
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:bean_bot/Pages/logs.dart';
import 'package:bean_bot/Pages/debug.dart';
import 'Providers/MQTTAppState.dart';
import 'package:bean_bot/Pages/homepage.dart';

void main() {
  runApp(MaterialApp(
    title: 'The Bean Bot',
    home: ChangeNotifierProvider<MQTTAppState>(
      create: (context) => MQTTAppState(),
      child:  BeanBot(),
    ),
  ));
}

class BeanBot extends StatefulWidget {
  const BeanBot({Key? key}) : super(key: key);

  @override
  _BeanBotState createState() => _BeanBotState();
}

class _BeanBotState extends State<BeanBot> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/' : (context) => HomePage(),
        '/debug': (context) => DebugPage(),
        '/logs': (context) => LogPage(),
      },
    );
  }
}