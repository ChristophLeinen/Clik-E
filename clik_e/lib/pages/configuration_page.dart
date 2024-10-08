import 'package:clik_e/pages/configuration_overview_page.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:clik_e/widgets/tile.dart';
import 'package:flutter/material.dart';

void navigate(context, String viewName, String tableName) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) =>
          ConfigurationOverviewPage(viewName: viewName, tableName: tableName),
    ),
  );
}

class ConfigurationPage extends StatelessWidget {
  const ConfigurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClikAppBar(
        title: "Verwaltung",
      ),
      body: Center(
        child: SizedBox(
          width: (176 + 16 + 176), // Tile + spacing + Tile
          child: GridView.count(
            padding: const EdgeInsets.all(20),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            crossAxisCount: 2,
            children: <Widget>[
              Tile(
                icon: Icons.edit_document,
                text: "Evaluierungsbögen",
                onPressed: () =>
                    navigate(context, "forms", "Evaluierungsbögen"),
              ),
              Tile(
                icon: Icons.question_answer,
                text: "Fragen",
                onPressed: () => navigate(context, "questions", "Fragen"),
              ),
              Tile(
                icon: Icons.apps,
                text: "Kompetenzen und Eigenschaften",
                onPressed: () => navigate(
                    context, "features", "Kompetenzen und Eigenschaften"),
              ),
              Tile(
                icon: Icons.lightbulb,
                text: "Vorschläge",
                onPressed: () => navigate(context, "suggestions", "Vorschläge"),
              ),
              Tile(
                icon: Icons.settings_suggest,
                text: "Vorschlagslogik",
                onPressed: () => navigate(context, "logics", "Vorschlagslogik"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
