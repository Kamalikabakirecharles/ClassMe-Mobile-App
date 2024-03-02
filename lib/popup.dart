import 'package:flutter/material.dart';

Future<void> showPopup(BuildContext context, String header, String body) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(header),
        content: Text(body),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the popup
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
