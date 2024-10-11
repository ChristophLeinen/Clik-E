import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/feature.dart';
import 'package:flutter/material.dart';

class Question extends DataObject {
  Question(super.id, this.question, this.feature);

  String question;
  String feature;

  factory Question.fromJson(dynamic parsedData) {
    final String id = parsedData["id"];
    String question = parsedData["question"];
    String feature = parsedData["feature"];
    return Question(id, question, feature);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "question": question,
      "feature": feature,
    };
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
  Widget getEditControls(
    Function updateView,
    Map<String, List<DataObject>> relatedObjects,
  ) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController questionController = TextEditingController();
    final TextEditingController featureController = TextEditingController();
    idController.text = id;
    questionController.text = question;
    featureController.text = feature;

    const double padding = 16;

    List<DropdownMenuEntry> featureItems = [];
    List<Feature> features = relatedObjects["features"]! as List<Feature>;
    for (int featureIndex = 0; featureIndex < features.length; ++featureIndex) {
      featureItems.add(DropdownMenuEntry(
        value: features[featureIndex].id,
        label: features[featureIndex].name,
      ));
    }

    return SizedBox(
      width: 600,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          const Text("Fragetext"),
          const SizedBox(
            height: padding / 2,
          ),
          SizedBox(
            width: 500,
            child: TextField(
              controller: questionController,
              onChanged: (String newValue) {
                question = newValue;
              },
            ),
          ),
          const SizedBox(
            height: padding,
          ),
          const Text("Kompetenz und Eigenschaft"),
          const SizedBox(
            height: padding / 2,
          ),
          DropdownMenu(
            initialSelection: feature,
            dropdownMenuEntries: featureItems,
            label: const Text("Wähle eine Kompetenz und Eigenschaft aus."),
            onSelected: (dynamic newValue) {
              feature = newValue as String;
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<Map<String, List<DataObject>>> getRelatedItems() async {
    List<Feature> features = await DataService<Feature>().getItems("features");
    return {"features": features};
  }
}
