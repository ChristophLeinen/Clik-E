import 'package:clik_e/pages/menu_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CliKASA());
}

class CliKASA extends StatelessWidget {
  const CliKASA({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "CliKASA",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MenuPage(),
    );
  }
}
