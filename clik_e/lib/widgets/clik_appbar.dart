import 'package:flutter/material.dart';

PreferredSizeWidget ClikAppBar({required String title}) {
  return AppBar(
    backgroundColor: Colors.blue,
    title: Center(child: Text(title)),
  );
}
