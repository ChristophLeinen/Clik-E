import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/logic.dart';
import 'package:flutter/material.dart';

class Suggestion extends DataObject {
  Suggestion(super.id, this.name, this.suggestionsInstructions,
      this.expertExplanation, this.expertReasoning, this.connectedLogics);

  String name;
  String suggestionsInstructions;
  String expertExplanation;
  String expertReasoning;
  List<String> connectedLogics;

  factory Suggestion.fromJson(dynamic parsedData) {
    final String id = parsedData["id"];
    String name = parsedData["name"];
    String suggestionsInstructions = parsedData["suggestionsInstructions"];
    String expertExplanation = parsedData["expertExplanation"];
    String expertReasoning = parsedData["expertReasoning"];
    List<String> connectedLogics =
        List<String>.from(parsedData["connectedLogics"]);
    return Suggestion(id, name, suggestionsInstructions, expertExplanation,
        expertReasoning, connectedLogics);
  }

  @override
  DataRow getDataRow(bool selected, Function onTap, int position) {
    void pressed() {
      onTap(position);
    }

    int connectedLogicsLength = connectedLogics.length;

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
          DataCell(Text("$connectedLogicsLength"), onTap: pressed),
        ]);
  }

  @override
  List<DataColumn> getColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Text("Name")),
      DataColumn(label: Text("Vorschlagsanweisung")),
      DataColumn(label: Text("Anzahl verbundener Regeln")),
    ];
  }

  @override
  Widget getEditControls(
    Function updateView,
    Map<String, List<DataObject>> relatedObjects,
  ) {
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

    const double padding = 16;

    List<DropdownMenuEntry> allLogics = [];
    List<DropdownMenuEntry> openLogics = [];

    Logic logic;
    for (int i = 0; i < relatedObjects["logics"]!.length; ++i) {
      logic = relatedObjects["logics"]![i] as Logic;
      if (!connectedLogics.contains(logic.id)) {
        openLogics.add(DropdownMenuEntry(value: logic.id, label: logic.name));
      }
      allLogics.add(DropdownMenuEntry(value: logic.id, label: logic.name));
    }

    Row createLogic(
      String logic,
      Function(String newValue) onSelectLogic,
      Function() onDeleteLogic,
    ) {
      List<DropdownMenuEntry> limitedLogics = [];

      limitedLogics.add(allLogics.firstWhere((DropdownMenuEntry dropDownItem) {
        return dropDownItem.value == logic;
      }));
      limitedLogics.addAll(openLogics);

      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownMenu(
          dropdownMenuEntries: limitedLogics,
          width: 500,
          label: const Text("Regel auswählen"),
          initialSelection: logic,
          onSelected: (dynamic newValue) {
            onSelectLogic(newValue as String);
          },
        ),
        SizedBox(
          width: padding,
        ),
        Tooltip(
          message: "Regel löschen",
          child: IconButton(
              onPressed: onDeleteLogic, icon: Icon(Icons.delete_forever)),
        ),
      ]);
    }

    Column logicColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );

    for (int logicIndex = 0;
        logicIndex < connectedLogics.length;
        ++logicIndex) {
      logicColumn.children
          .add(createLogic(connectedLogics[logicIndex], (String newValue) {
        connectedLogics[logicIndex] = newValue;
        updateView();
      }, () {
        connectedLogics.remove(connectedLogics[logicIndex]);
        updateView();
      }));
      logicColumn.children.add(SizedBox(
        height: padding,
      ));
    }

    if (openLogics.isNotEmpty) {
      logicColumn.children.add(ElevatedButton(
          onPressed: () {
            connectedLogics.add(openLogics[0].value);
            updateView();
          },
          child: const Text("Regel hinzufügen")));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("ID"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: idController,
          enabled: false,
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Name"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: nameController,
          onChanged: (String newValue) {
            name = newValue;
          },
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Vorschlagsanweisung"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: suggestionsInstructionsController,
          onChanged: (String newValue) {
            suggestionsInstructions = newValue;
          },
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Didaktische Erläuterung"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: expertExplanationController,
          onChanged: (String newValue) {
            expertExplanation = newValue;
          },
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Didaktische Begründung"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: expertReasoningController,
          onChanged: (String newValue) {
            expertReasoning = newValue;
          },
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Regeln für diesen Vorschlag"),
      const SizedBox(
        height: padding,
      ),
      logicColumn,
    ]);
  }

  @override
  Future<Map<String, List<DataObject>>> getRelatedItems() async {
    List<Logic> logics = await DataService<Logic>().getItems("logics");
    return {"logics": logics};
  }
}
