
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Providers/MQTTAppState.dart';
import 'package:bean_bot/Pages/homepage.dart';

void main() {
  runApp(MaterialApp(
    title: 'The Bean Bot',
    home: ChangeNotifierProvider<MQTTAppState>(
      create: (_) => MQTTAppState(),
      child: const BeanBot(),
    ),
  ));
}