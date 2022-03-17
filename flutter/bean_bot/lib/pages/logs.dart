import 'package:flutter/material.dart';
import 'package:bean_bot/Providers/mqtt_app_state.dart';
import 'package:provider/provider.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);
  @override
  _logPageState createState() => _logPageState();
}

class _logPageState extends State<LogPage> {
  @override
  Widget build(BuildContext context) {
    final MQTTAppState appState =
        Provider.of<MQTTAppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
      ),
      body: ListView(
        children: [
          _buildConnectionStateText(
            _prepareStateMessageFrom(
                Provider.of<MQTTAppState>(context).getAppConnectionState),
            setColor(Provider.of<MQTTAppState>(context).getAppConnectionState),
          ),
          _buildLogText(appState.getLogText),
          _buildLogDeleteButton(context, appState, appState.getAppConnectionState),
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

  Widget _buildLogDeleteButton(BuildContext context, MQTTAppState appState,
      MQTTAppConnectionState connectionState) {
    return Row(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(8),
          child: ElevatedButton(
            onPressed: disableTextField(connectionState) ? () {
                appState.deleteLogText();
            }: null,
            child: const Text('Delete logs'),

          ),
        ),),
      ],
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

}
