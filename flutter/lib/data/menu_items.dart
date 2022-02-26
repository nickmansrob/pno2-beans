import 'package:flutter/material.dart';
import 'package:pno2_beans/model/menu_item.dart';

class MenuItems {
  static const List<MenuItem> items = [
    itemDebug,
    itemLog,
  ];
  static const itemDebug = MenuItem(
    text: 'Debug Menu',
  );
  static const itemLog = MenuItem(
    text: 'Logs',
  );
}