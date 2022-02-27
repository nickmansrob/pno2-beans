import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Logs'),
        ),
        body: (Container(
          child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Output',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )
              ]),
          margin:
              const EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 40),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
          ),
        )),
      );
}
