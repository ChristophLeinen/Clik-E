import 'package:flutter/material.dart';

Widget Tile(
    {required String text,
    required IconData icon,
    required void Function() onPressed}) {
  return ConstrainedBox(
    constraints: const BoxConstraints(
      minWidth: 176,
      maxWidth: 176,
      minHeight: 176,
      maxHeight: 176,
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      onPressed: onPressed,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64),
            const SizedBox(height: 15),
            Text(text),
          ],
        ),
      ),
    ),
  );
}
