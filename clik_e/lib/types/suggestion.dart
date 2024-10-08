import 'package:clik_e/types/data_object.dart';
import 'package:flutter/material.dart';

class Suggestion extends DataObject {
  const Suggestion(id, this.name, this.suggestionsInstructions,
      this.expertExplanation, this.expertReasoning)
      : super(id);

  final String name;
  final String suggestionsInstructions;
  final String expertExplanation;
  final String expertReasoning;

  factory Suggestion.fromJson(dynamic parsedData) {
    final id = parsedData["id"] as String;
    final name = parsedData["name"] as String;
    final suggestionsInstructions =
        parsedData["suggestionsInstructions"] as String;
    final expertExplanation = parsedData["expertExplanation"] as String;
    final expertReasoning = parsedData["expertReasoning"] as String;
    return Suggestion(
        id, name, suggestionsInstructions, expertExplanation, expertReasoning);
  }

  @override
  DataRow getDataRow(bool selected, Function onTap, int position) {
    void pressed() {
      onTap(position);
    }

    return DataRow(
        color:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.lightBlue;
          }
          return null; // Use the default value.
        }),
        selected: selected,
        cells: [
          DataCell(Text(id), onTap: pressed),
          DataCell(Text(name), onTap: pressed),
          DataCell(Text(suggestionsInstructions), onTap: pressed),
          DataCell(Text(expertExplanation), onTap: pressed),
          DataCell(Text(expertReasoning), onTap: pressed),
        ]);
  }

  @override
  List<DataColumn> getColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Text("Name")),
      DataColumn(label: Text("Vorschlagsanweisung")),
      DataColumn(label: Text("Didaktische Erläuterung")),
      DataColumn(label: Text("Didaktische Begründung")),
    ];
  }

  @override
  Widget getEditControls() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController suggestionsInstructionsController =
        TextEditingController();
    final TextEditingController expertExplanationController =
        TextEditingController();
    final TextEditingController expertReasoningController =
        TextEditingController();
    idController.text = id;
    nameController.text = name;
    suggestionsInstructionsController.text = suggestionsInstructions;
    expertExplanationController.text = expertExplanation;
    expertReasoningController.text = expertReasoning;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("ID"),
      const SizedBox(height: 8),
      TextField(
        controller: idController,
        enabled: false,
      ),
      const SizedBox(height: 16),
      const Text("Name"),
      const SizedBox(height: 8),
      TextField(
        controller: nameController,
      ),
      const SizedBox(height: 16),
      const Text("Vorschlagsanweisung"),
      const SizedBox(height: 8),
      TextField(
        controller: suggestionsInstructionsController,
      ),
      const SizedBox(height: 16),
      const Text("Didaktische Erläuterung"),
      const SizedBox(height: 8),
      TextField(
        controller: expertExplanationController,
      ),
      const SizedBox(height: 16),
      const Text("Didaktische Begründung"),
      const SizedBox(height: 8),
      TextField(
        controller: expertReasoningController,
      ),
    ]);
  }
}
