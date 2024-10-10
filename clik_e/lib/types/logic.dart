import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/feature.dart';
import 'package:flutter/material.dart';

class Logic extends DataObject {
  Logic(id, this.name, this.weightedFeatures) : super(id);

  String name;
  Map<String, double> weightedFeatures;

  factory Logic.fromJson(dynamic parsedData) {
    String id = parsedData["id"];
    String name = parsedData["name"];
    Map<String, double> weightedFeatures =
        Map<String, double>.from(parsedData["weightedFeatures"]);
    return Logic(id, name, weightedFeatures);
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
        ]);
  }

  @override
  List<DataColumn> getColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Text("Name")),
    ];
  }

  @override
  Widget getEditControls(
    Function updateView,
    Map<String, List<DataObject>> relatedObjects,
  ) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    idController.text = id;
    nameController.text = name;

    const double padding = 16;

    List<DropdownMenuEntry> allFeatures = [];
    List<DropdownMenuEntry> openFeatures = [];

    Feature feature;

    for (int i = 0; i < relatedObjects["features"]!.length; ++i) {
      feature = relatedObjects["features"]![i] as Feature;
      if (!weightedFeatures.keys.contains(feature.id)) {
        openFeatures
            .add(DropdownMenuEntry(value: feature.id, label: feature.name));
      }
      allFeatures
          .add(DropdownMenuEntry(value: feature.id, label: feature.name));
    }

    Row createFeature(
        String feature,
        double value,
        Function(String, double, String) onSelected,
        Function(double, String) changeValue,
        Function(String) deleteFeature) {
      List<DropdownMenuEntry> limitedFeatures = [];

      limitedFeatures
          .add(allFeatures.firstWhere((DropdownMenuEntry dropDownItem) {
        return dropDownItem.value == feature;
      }));
      limitedFeatures.addAll(openFeatures);

      return Row(children: [
        DropdownMenu(
          dropdownMenuEntries: limitedFeatures,
          width: 350,
          label: const Text("Kompetenz und Eigenschaft auswählen"),
          initialSelection: feature,
          onSelected: (dynamic newKey) {
            onSelected(newKey as String, value, feature);
          },
        ),
        SizedBox(
          width: padding,
        ),
        Text("Gewichtung:"),
        SizedBox(
          width: padding / 2,
        ),
        SizedBox(
          width: 350,
          child: Slider(
              onChanged: (double newValue) {
                changeValue(newValue, feature);
              },
              value: value,
              min: -10,
              max: 10,
              divisions: 21,
              label: value.round().toString()),
        ),
        SizedBox(
          width: padding / 2,
        ),
        Tooltip(
          message: "Kompetenz und Eigenschaft löschen",
          child: IconButton(
              onPressed: () {
                deleteFeature(feature);
              },
              icon: Icon(Icons.delete_forever)),
        ),
      ]);
    }

    Column weightedFeatureColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );

    for (String feature in weightedFeatures.keys) {
      weightedFeatureColumn.children.add(
          createFeature(feature, weightedFeatures[feature]!,
              (String newKey, double newValue, String oldKey) {
        weightedFeatures.remove(oldKey);
        weightedFeatures[newKey] = newValue;
        updateView();
      }, (double newValue, String key) {
        weightedFeatures[key] = newValue;
        updateView();
      }, (String key) {
        weightedFeatures.remove(key);
        updateView();
      }));
      weightedFeatureColumn.children.add(SizedBox(
        height: padding,
      ));
    }

    if (openFeatures.isNotEmpty) {
      weightedFeatureColumn.children.add(ElevatedButton(
          onPressed: () {
            weightedFeatureColumn.children.insert(
                weightedFeatureColumn.children.length - 2,
                createFeature(openFeatures[0].value, 0,
                    (String newKey, double newValue, String oldKey) {
                  weightedFeatures.remove(oldKey);
                  weightedFeatures[newKey] = newValue;
                  updateView();
                }, (double newValue, String key) {
                  weightedFeatures[key] = newValue;
                  updateView();
                }, (String key) {
                  weightedFeatures.remove(key);
                  updateView();
                }));
            weightedFeatures[openFeatures[0].value] = 0;
            updateView();
          },
          child: const Text("Kompetenz und Eigenschaft hinzufügen")));
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
            }),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Gewichtete Kompetenzen und Eigenschaften"),
      const SizedBox(
        height: padding,
      ),
      weightedFeatureColumn,
    ]);
  }

  @override
  Future<Map<String, List<DataObject>>> getRelatedItems() async {
    List<Feature> features = await DataService<Feature>().getItems("features");
    return {"features": features};
  }
}
