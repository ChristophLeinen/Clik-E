import 'package:clik_e/types/data_object.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat("dd.MM.yyyy HH:mm");

class Section {
  const Section(this.label, this.questions);

  final String label;
  final List<String> questions;

  factory Section.fromJson(dynamic parsedData) {
    final label = parsedData["label"] as String;
    final questions = List<String>.from(parsedData["questions"]);
    return Section(label, questions);
  }
}

class EvaluationForm extends DataObject {
  const EvaluationForm(id, this.name, this.description, this.creationDate,
      this.modificationDate, this.sections, this.suggestions)
      : super(id);

  final String name;
  final String description;
  final DateTime creationDate;
  final DateTime modificationDate;
  final List<Section> sections;
  final List<String> suggestions;

  factory EvaluationForm.fromJson(dynamic parsedData) {
    final id = parsedData["id"] as String;
    final name = parsedData["name"] as String;
    final description = parsedData["description"] as String;
    final creationDate = DateTime.parse((parsedData["creationDate"]));
    final modificationDate = DateTime.parse((parsedData["modificationDate"]));
    List<Section> sections = [];
    final parsedSections = parsedData["sections"];
    for (var i = 0; i < parsedSections.length; ++i) {
      sections.add(Section.fromJson(parsedSections[i]));
    }
    final suggestions = List<String>.from(parsedData["suggestions"]);
    return EvaluationForm(id, name, description, creationDate, modificationDate,
        sections, suggestions);
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
          DataCell(
              Column(
                children: [Text(name), Text(description)],
              ),
              onTap: pressed),
          DataCell(
              Column(
                children: [
                  Text(formatter.format(creationDate)),
                  Text(formatter.format(modificationDate))
                ],
              ),
              onTap: pressed),
        ]);
  }

  @override
  List<DataColumn> getColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Column(children: [Text("Name"), Text("Beschreibung")])),
      DataColumn(
          label: Column(children: [Text("Erstellt"), Text("Zuletzt geändert")]))
    ];
  }

  @override
  Widget getEditControls() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController creationDateController =
        TextEditingController();
    final TextEditingController modificationDateController =
        TextEditingController();
    idController.text = id;
    nameController.text = name;
    descriptionController.text = description;
    creationDateController.text = formatter.format(creationDate);
    modificationDateController.text = formatter.format(modificationDate);

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
      const Text("Beschreibung"),
      const SizedBox(height: 8),
      TextField(
        controller: descriptionController,
      ),
      const SizedBox(height: 16),
      const Text("Erstellt"),
      const SizedBox(height: 8),
      TextField(
        controller: creationDateController,
        enabled: false,
      ),
      const SizedBox(height: 16),
      const Text("Zuletzt geändert"),
      const SizedBox(height: 8),
      TextField(
        controller: modificationDateController,
        enabled: false,
      ),
    ]);
  }
}
