import 'package:flutter/material.dart';

Widget MenuOption({
  required String text,
  required IconData icon,
  required void Function() onPressed,
}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Icon(icon),
        SizedBox(
          width: 150,
          child: Text(text),
        )
      ],
    ),
  );
}
