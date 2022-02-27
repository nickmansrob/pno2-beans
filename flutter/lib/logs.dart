import 'package:flutter/material.dart';
import 'package:pno2_beans/data/menu_items.dart';
import 'package:pno2_beans/model/menu_item.dart';

class LogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Logs'),
        ),
        body: (Container(
          child: Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[

            Text(
              'Output',
              style: TextStyle(
                fontSize: 20,
              ),

            )
          ]),
          margin: const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 40),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
          ),
        )),
      );
}
