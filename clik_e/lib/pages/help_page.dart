import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CliKASAAppBar(
        title: "Hilfe",
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Center(),
        ),
      ),
    );
  }
}
