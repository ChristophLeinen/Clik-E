import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:clik_e/pages/analyze_page.dart';
import 'package:flutter/material.dart';

class AnalyzeSelectionPage extends StatefulWidget {
  const AnalyzeSelectionPage({super.key});

  @override
  State<AnalyzeSelectionPage> createState() => _AnalyzeSelectionPageState();
}

class _AnalyzeSelectionPageState extends State<AnalyzeSelectionPage> {
  List<DropdownMenuEntry> dropdownMenuEntries = [
    const DropdownMenuEntry(
      value: "123456",
      label: "Analyse1",
    ),
    const DropdownMenuEntry(
      value: "1337",
      label: "Analyse2",
    ),
    const DropdownMenuEntry(
      value: "404",
      label: "Analyse3",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CliKASAAppBar(
        title: "Analyse",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownMenu(
                  onSelected: (evalId) {
                    if (evalId != null) {
                      setState(() {
                        // _evalId = evalId;
                      });
                    }
                  },
                  width: 300,
                  enableFilter: true,
                  dropdownMenuEntries: dropdownMenuEntries,
                  label: const Text("Wählen Sie einen Analyse aus."),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnalyzePage(),
                        ),
                      );
                    },
                    child: const Text("Evaluierung starten"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
