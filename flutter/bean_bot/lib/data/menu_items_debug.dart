import 'package:bean_bot/model/menu_item.dart';

class MenuItems {
  static const List<MenuItem> items = [
    itemLog,
    itemColor
  ];

  static const itemLog = MenuItem(
    text: 'Logs',
  );
  static const itemColor = MenuItem(
    text: 'Color Calibration',
  );
}
