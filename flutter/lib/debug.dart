import 'package:flutter/material.dart';
import 'package:pno2_beans/data/menu_items.dart';
import 'package:pno2_beans/model/menu_item.dart';

class DebugPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Debug Menu'),
        ),
        body: (Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        left: 8, top: 8, right: 8, bottom: 0),
                    child: Text(
                      'Motors',
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
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Toggle 1'),
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
                        child: Text('Toggle 2'),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                indent: 8,
                endIndent: 8,
              ),
              Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('APLLY'),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('APPLY'),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(
                indent: 8,
                endIndent: 8,
              ),
              Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
                Padding(
                    padding: const EdgeInsets.only(
                        left: 8, top: 0, right: 8, bottom: 4),
                    child: Text(
                      'Arduino',
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Reset'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Reconnect'),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Check Conncetion'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Print IP'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      child: Text('Output'),
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
              Divider(
                indent: 8,
                endIndent: 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Read Weigth'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Read color'),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Read position'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                        },
                        child: Text('Read magnet'),
                      ),
                    ),
                  ),
                ],
              ),
          Row(
                  children: [
                    Expanded(
                      child: Container(
                        child: Text('Readouts'),
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

            ],
          ),
        )),
      );
}
