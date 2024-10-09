import 'package:flutter/material.dart';

class DataObject {
  final String id;

  const DataObject(this.id);

  factory DataObject.fromJson(dynamic parsedData) {
    final id = parsedData["id"] as String;
    return DataObject(id);
  }

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
        cells: [DataCell(Text(id), onTap: pressed)]);
  }

  List<DataColumn> getColumns() {
    return const [DataColumn(label: Text("ID"))];
  }

  Widget getEditControls(Function updateView) {
    final TextEditingController idController = TextEditingController();
    idController.text = id;

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text("ID"),
      const SizedBox(height: 8),
      TextField(
        controller: idController,
        enabled: false,
      ),
    ]);
  }
}
