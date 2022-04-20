import 'package:bean_bot/data/menu_items_logs.dart';
import 'package:bean_bot/model/menu_item.dart';
import 'package:bean_bot/providers/mqtt_app_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  /////////////////////////// Widgets ///////////////////////////
  @override
  // Creates the main widget of the Log page.
  Widget build(BuildContext context) {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
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
          _buildConnectionStateText(
            statusBarMessage(
                Provider.of<MQTTAppState>(context).getAppConnectionState),
            setColorStatusBar(
                Provider.of<MQTTAppState>(context).getAppConnectionState),
          ),
          _buildLogText(appState.getLogText),
          _buildLogDeleteButton(
              context, appState, appState.getAppConnectionState),
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
            ),
          ),
        ),
      ],
    );
  }

  // Builds the header of the container of the incoming log texts.
  Widget _buildLogText(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Arduino logs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: InputDecorator(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
            ),
            child: _buildScrollableTextWith(context, text),
          ),
        ),
      ],
    );
  }

  // Creates the container to display to incoming log texts.
  Widget _buildScrollableTextWith(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: 400,
        height: 500,
        child: SingleChildScrollView(
          child: Text(text),
        ),
      ),
    );
  }

  // Creates the button to clear out the logs.
  Widget _buildLogDeleteButton(BuildContext context, MQTTAppState appState,
      MQTTAppConnectionState connectionState) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: () {
                appState.deleteLogText();
              },
              child: const Text('Delete logs'),
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.red,
                onSurface: Colors.redAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /////////////////////////// Helper functions ///////////////////////////
  // Gets the message for the status bar on top of the screen.
  String statusBarMessage(MQTTAppConnectionState state) {
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

  // Function to disable text-fields when not connected to the broker.
  bool disableTextField(MQTTAppConnectionState state) {
    if (state == MQTTAppConnectionState.disconnected ||
        state == MQTTAppConnectionState.connecting) {
      return false;
    } else {
      return true;
    }
  }

  //// Navigation Menu
  // Handles the navigation of the popupmenu.
  void onSelected(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.itemDebug:
        Navigator.popAndPushNamed(context, '/debug');
        break;
      case MenuItems.itemColor:
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
