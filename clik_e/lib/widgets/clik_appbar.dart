import 'package:flutter/material.dart';

PreferredSizeWidget CliKASAAppBar({required String title}) {
  return AppBar(
    backgroundColor: Colors.blue,
    title: Center(child: Text(title)),
  );
}
