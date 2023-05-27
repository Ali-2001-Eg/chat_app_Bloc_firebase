import 'package:flutter/material.dart';

void navTo(BuildContext context, Widget page) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}

void navToWithReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ));
}

void showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      message,
      style: const TextStyle(fontSize: 14),
    ),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    elevation: 0,
    action: SnackBarAction(
      onPressed: () {},
      label: 'OK',
      textColor: Colors.white,
    ),
  ));
}
