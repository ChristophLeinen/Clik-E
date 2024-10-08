import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:flutter/material.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClikAppBar(
        title: "Analyse",
      ),
      body: const Center(
        child: SingleChildScrollView(
          child: Center(),
        ),
      ),
    );
  }
}
