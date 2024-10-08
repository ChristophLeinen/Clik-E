import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:clik_e/widgets/menu_option.dart';
import 'package:clik_e/pages/analyze_selection_page.dart';
import 'package:clik_e/pages/configuration_page.dart';
import 'package:clik_e/pages/evaluation_selection_page.dart';
import 'package:clik_e/pages/help_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  final double padding = 15;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CliKASAAppBar(
        title: "Hauptmenü",
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: 250.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  MenuOption(
                    text: "Evaluation",
                    icon: Icons.edit_document,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EvaluationSelectionPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: padding),
                  MenuOption(
                    text: "Analyze",
                    icon: Icons.analytics,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AnalyzeSelectionPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: padding),
                  MenuOption(
                    text: "Verwaltung",
                    icon: Icons.settings,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ConfigurationPage(),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: padding),
                  MenuOption(
                    text: "Hilfe",
                    icon: Icons.help,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const HelpPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
