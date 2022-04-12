import 'package:bean_bot/model/menu_item.dart';

class MenuItems {
  static const List<MenuItem> items = [
    itemDebug,
    itemColor
  ];

  static const itemDebug = MenuItem(
    text: 'Debug Menu',
  );
  static const itemColor = MenuItem(
    text: 'Color Calibration',
  );
}
