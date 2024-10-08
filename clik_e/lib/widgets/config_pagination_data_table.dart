import 'package:clik_e/types/data_object.dart';
import 'package:flutter/material.dart';

class ConfigurationDataTable<T extends DataObject> extends StatefulWidget {
  const ConfigurationDataTable(
      {super.key,
      required this.title,
      required this.items,
      required this.onAddRow,
      required this.onCopyRow,
      required this.onDeleteRow,
      required this.onEditRow});

  final String title;
  final List<T> items;
  final Function onAddRow;
  final Function(int rowNumber) onCopyRow;
  final Function(int rowNumber) onDeleteRow;
  final Function(int rowNumber) onEditRow;

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

  @override
  Widget build(BuildContext context) {
    void selected(int rowNumber) {
      setState(() {
        selectedItem = selectedItem == rowNumber ? -1 : rowNumber;
      });
    }

    return PaginatedDataTable(
        header: Text(widget.title),
        actions: [
          ElevatedButton(
              onPressed: () {
                widget.onAddRow();
              },
              child: const Text("Hinzufügen")),
          ElevatedButton(
              onPressed: selectedItem != -1
                  ? () {
                      widget.onEditRow(selectedItem);
                    }
                  : null,
              child: const Text("Bearbeiten")),
          ElevatedButton(
              onPressed: selectedItem != -1
                  ? () {
                      widget.onCopyRow(selectedItem);
                    }
                  : null,
              child: const Text("Kopieren")),
          ElevatedButton(
              onPressed: selectedItem != -1
                  ? () {
                      widget.onDeleteRow(selectedItem);
                    }
                  : null,
              child: const Text("Löschen"))
        ],
        source: MyDataTableSource(
            items: widget.items, selectedRow: selectedItem, onTap: selected),
        sortColumnIndex: 0,
        sortAscending: true,
        columns: widget.items[0].getColumns());
  }
}

class MyDataTableSource<T extends DataObject> extends DataTableSource {
  MyDataTableSource(
      {required this.items, required this.selectedRow, required this.onTap});

  final List<T> items;
  int selectedRow;
  final Function onTap;

  @override
  DataRow? getRow(int index) {
    return items[index].getDataRow(index == selectedRow, onTap, index);
  }

  @override
  // Currently we always require the full data, but this can of course be changed in the future.
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => items.length;

  @override
  // This ensures that the table title is not overwritten with the selected elements count.
  int get selectedRowCount => 0;
}
