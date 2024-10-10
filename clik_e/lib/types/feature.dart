import 'package:clik_e/types/data_object.dart';
import 'package:flutter/material.dart';

class Feature extends DataObject {
  const Feature(id, this.name) : super(id);

  final String name;

  factory Feature.fromJson(dynamic parsedData) {
    final id = parsedData["id"] as String;
    final name = parsedData["name"] as String;
    return Feature(id, name);
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
    ]);
  }
}
