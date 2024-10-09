import 'package:clik_e/types/data_object.dart';
import 'package:flutter/material.dart';

Widget _ConfigurationDataTableHeader(
    {required String title, Map<String, Function()?>? actions}) {
  List<Widget> actionRowItems = [];
  if (actions != null) {
    for (String key in actions.keys) {
      actionRowItems
          .add(ElevatedButton(onPressed: actions[key], child: Text(key)));
      actionRowItems.add(const SizedBox(width: 8));
    }

    actionRowItems.removeLast();
  }

  return Container(
      decoration: BoxDecoration(border: Border.all()),
      padding: const EdgeInsets.all(8),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(title), Row(children: actionRowItems)]));
}

class ConfigurationDataTable<T extends DataObject> extends StatefulWidget {
  const ConfigurationDataTable(
      {super.key, required this.title, required this.items});

  final String title;
  final List<T> items;

  @override
  _ConfigurationDataTableState createState() =>
      _ConfigurationDataTableState<T>();
}

class _ConfigurationDataTableState<T extends DataObject>
    extends State<ConfigurationDataTable> {
  late int selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = -1;
  }

  List<DataRow> _createDataTableRows(List<DataObject> items) {
    final List<DataRow> tableRows = [];
    for (int i = 0; i < items.length; ++i) {
      void onTap() {
        setState(() {
          selectedItem = selectedItem == i ? -1 : i;
        });
      }

      tableRows.add(items[i].getDataRow(selectedItem == i, onTap, i));
    }

    return tableRows;
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Function()?> actionMap = {
      "Hinzufügen": () {},
      "Bearbeiten": selectedItem != -1 ? () {} : null,
      "Kopieren": selectedItem != -1 ? () {} : null,
      "Löschen": selectedItem != -1 ? () {} : null
    };
    final List<DataRow> tableRows = [];

    tableRows.addAll(_createDataTableRows(widget.items));

    return Column(children: [
      _ConfigurationDataTableHeader(title: widget.title, actions: actionMap),
      DataTable(
        sortColumnIndex: 0,
        sortAscending: true,
        columns: widget.items[0].getColumns(),
        border: TableBorder.all(),
        rows: tableRows,
      )
    ]);
  }
}
