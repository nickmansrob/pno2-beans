import 'package:flutter/material.dart';
// import 'package:pno2_beans/data/menu_items.dart';
// import 'package:pno2_beans/model/menu_item.dart';

class DebugPage extends StatelessWidget {
  const DebugPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Debug Menu'),
        ),
        body:
            ListView(children: const [Motors(), ServoInput(), Arduino(), ReadOuts()]),
      );
}

class Motors extends StatelessWidget {
  const Motors({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(mainAxisSize: MainAxisSize.max, children: const <Widget>[
             Padding(
                 padding:
                     EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
                child:  Text(
                  'Motors',
                  style:  TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ))
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Toggle 1'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Respond to button press
                    },
                    child: const Text('Toggle 2'),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            indent: 8,
            endIndent: 8,
          ),
        ],
      );
  }
}

class ServoInput extends StatefulWidget {
  const ServoInput({Key? key}) : super(key: key);

  @override
  _ServoInputState createState() => _ServoInputState();
}

class _ServoInputState extends State<ServoInput> {
  final _servoForm = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _servoForm,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisSize: MainAxisSize.max, children: const <Widget>[
              Padding(
                  padding: EdgeInsets.only(
                      left: 8, top: 0, right: 8, bottom: 4),
                  child: Text(
                    'Servos',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ))
            ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Degrees first',
                        isDense: true,
                        contentPadding: EdgeInsets.all(10),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of degrees';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Respond to button press
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Degrees second',
                          isDense: true,
                          contentPadding: EdgeInsets.all(10)),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the number of degrees';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    child: ElevatedButton(
                      onPressed: () {
                        // Respond to button press
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(
              indent: 8,
              endIndent: 8,
            ),
          ],
        ));
  }
}

class Arduino extends StatelessWidget {
  const Arduino({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisSize: MainAxisSize.max,
        children: const <Widget>[
          Padding(
            padding:
                 EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
            child: Text(
              'Arduino',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Reset'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Reconnect'),
              ),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Check connection'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Print IP'),
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              child: const Text('Output'),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
      const Divider(
        indent: 8,
        endIndent: 8,
      ),
    ]);
  }
}

class ReadOuts extends StatelessWidget {
  const ReadOuts({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: const <Widget>[Padding(
          padding:
          EdgeInsets.only(left: 8, top: 0, right: 8, bottom: 4),
          child: Text(
            'Readouts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Read weight'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Read color'),
              ),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Read position'),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ElevatedButton(
                onPressed: () {
                  // Respond to button press
                },
                child: const Text('Read magnet'),
              ),
            ),
          ),
        ],
      ),
      Row(
        children: [
          Expanded(
            child: Container(
              child: const Text('Readouts'),
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border.all(
                  width: 1,
                  color: Colors.blue,
                ),
              ),
            ),
          )
        ],
      ),
    ]);
  }
}