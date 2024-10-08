import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget _ConfigTableHeader(
    {required String title, Map<String, Function()?>? actions}) {
  List<Widget> actionRowItems = [];
  if (actions != null) {
    for (var key in actions.keys) {
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

TableRow _createTableColumnHeaders(List<dynamic> columnNames, bool withRadio) {
  final List<TableCell> columnHeaders = [];

  if (withRadio) {
    columnHeaders.add(TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
            height: 32, padding: const EdgeInsetsDirectional.only(start: 8))));
  }

  for (var i = 0; i < columnNames.length; i++) {
    columnHeaders.add(TableCell(
        verticalAlignment: TableCellVerticalAlignment.middle,
        child: Container(
            height: 32,
            padding: const EdgeInsetsDirectional.only(start: 8),
            child: Center(child: Text(columnNames[i].toString())))));
  }

  return TableRow(children: columnHeaders);
}

class ConfigurationTable extends StatefulWidget {
  const ConfigurationTable(
      {super.key,
      required this.title,
      this.columnNames,
      required this.rawData,
      this.selectable});

  final String title;
  final List<dynamic>? columnNames;
  final List<dynamic> rawData;
  final bool? selectable;

  @override
  _ConfigurationTableState createState() => _ConfigurationTableState();
}

class _ConfigurationTableState extends State<ConfigurationTable> {
  Map<String, Function()?> actionMap = {
    "Hinzufügen": () {},
    "Bearbeiten": null,
    "Kopieren": null,
    "Löschen": null
  };

  late int selectedItem;

  @override
  void initState() {
    super.initState();
    selectedItem = -1;
  }

  List<TableRow> _createTableRows(List<dynamic> rawData, bool withRadio) {
    final List<TableRow> tableRows = [];

    for (var i = 0; i < rawData.length; i++) {
      final dataRow = rawData[i];
      final List<TableCell> properties = [];

      if (withRadio) {
        properties.add(TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Expanded(
                child: Container(
                    color: selectedItem == i ? Colors.lightBlue.shade50 : null,
                    child: Padding(
                        padding:
                            const EdgeInsetsDirectional.only(start: 8, end: 8),
                        child: Radio(
                          value: selectedItem == i,
                          groupValue: selectedItem,
                          onChanged: (value) {
                            setState(() {
                              selectedItem = i;
                            });
                          },
                        ))))));
      }

      for (var key in dataRow.keys) {
        properties.add(TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Expanded(
                child: Container(
                    color: selectedItem == i ? Colors.lightBlue.shade50 : null,
                    child: Padding(
                        padding:
                            const EdgeInsetsDirectional.only(start: 8, end: 8),
                        child: Text(dataRow[key].toString()))))));
      }

      tableRows.add(TableRow(children: properties));
    }

    return tableRows;
  }

  @override
  Widget build(BuildContext context) {
    final bool withRadio = widget.selectable != null && widget.selectable!;
    final List<TableRow> tableRows = [];

    if (widget.columnNames != null) {
      tableRows.add(_createTableColumnHeaders(widget.columnNames!, withRadio));
    }

    tableRows.addAll(_createTableRows(widget.rawData, withRadio));

    return Column(children: [
      _ConfigTableHeader(
          title: widget.title, actions: withRadio ? actionMap : null),
      Table(
        columnWidths: withRadio ? const {0: FixedColumnWidth(32)} : null,
        border: TableBorder.all(),
        children: tableRows,
      )
    ]);
  }
}
