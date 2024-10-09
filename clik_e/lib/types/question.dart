import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/feature.dart';
import 'package:flutter/material.dart';

class Question extends DataObject {
  const Question(id, this.question, this.feature) : super(id);

  final String question;
  final String feature;

  factory Question.fromJson(dynamic parsedData) {
    final id = parsedData["id"] as String;
    final question = parsedData["question"] as String;
    final feature = parsedData["feature"] as String;
    return Question(id, question, feature);
  }

  @override
  DataRow getDataRow(bool selected, Function onTap, int position) {
    void pressed() {
      onTap(position);
    }

    Future<Feature> getFeatureById(String featureId) async {
      return await DataService<Feature>().getItem("features", featureId);
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
          DataCell(Text(question), onTap: pressed),
          DataCell(
              FutureBuilder(
                  future: getFeatureById(feature),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(feature);
                    }

                    return Text(snapshot.data!.name);
                  }),
              onTap: pressed),
        ]);
  }

  @override
  List<DataColumn> getColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Text("Fragentext")),
      DataColumn(label: Text("Kompetenz und Eigenschaft")),
    ];
  }

  @override
  Widget getEditControls(Function updateView) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController questionController = TextEditingController();
    final TextEditingController featureController = TextEditingController();
    idController.text = id;
    questionController.text = question;
    featureController.text = feature;

    Future<List<Feature>> getAllFeatures() async {
      return await DataService<Feature>().getItems("features");
    }

    List<DropdownMenuEntry> itemGenerator(List<Feature> features) {
      List<DropdownMenuEntry> items = [];
      for (int i = 0; i < features.length; ++i) {
        items.add(
            DropdownMenuEntry(value: features[i].id, label: features[i].name));
      }

      return items;
    }

    return SizedBox(
        width: 600,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text("ID"),
          const SizedBox(height: 8),
          TextField(
            controller: idController,
            enabled: false,
          ),
          const SizedBox(height: 16),
          const Text("Fragetext"),
          const SizedBox(height: 8),
          TextField(
            controller: questionController,
          ),
          const SizedBox(height: 16),
          const Text("Kompetenz und Eigenschaft"),
          const SizedBox(height: 8),
          FutureBuilder(
              future: getAllFeatures(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.hasError && !snapshot.hasData) {
                  return TextField(
                    controller: featureController,
                    enabled: false,
                  );
                }

                if (!snapshot.hasData) {
                  return const Text("Eintrag nicht gefunden.");
                }

                return DropdownMenu(
                  initialSelection: feature,
                  dropdownMenuEntries: itemGenerator(snapshot.data!),
                  label:
                      const Text("Wähle eine Kompetenz und Eigenschaft aus."),
                );
              }),
        ]));
  }
}
