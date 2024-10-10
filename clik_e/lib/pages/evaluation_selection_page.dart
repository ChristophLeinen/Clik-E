import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:flutter/material.dart';
import 'package:clik_e/pages/evaluation_page.dart';

class EvaluationSelectionPage extends StatefulWidget {
  const EvaluationSelectionPage({super.key});

  @override
  State<EvaluationSelectionPage> createState() =>
      _EvaluationSelectionPageState();
}

class BackendData {
  const BackendData(this.forms);

  final List<EvaluationForm> forms;
}

Future<BackendData> getBackendData() async {
  DataService formsService = DataService<EvaluationForm>();
  List<EvaluationForm> forms =
      await formsService.getItems("forms") as List<EvaluationForm>;

  return BackendData(forms);
}

class _EvaluationSelectionPageState extends State<EvaluationSelectionPage> {
  late Future<BackendData> _backendData;
  String _formId = "";
  String _type = "text";

  @override
  void initState() {
    super.initState();
    _backendData = getBackendData();
  }

  List<DropdownMenuEntry> itemGenerator(List<EvaluationForm> forms) {
    List<DropdownMenuEntry> items = [];
    for (int i = 0; i < forms.length; ++i) {
      items.add(DropdownMenuEntry(value: forms[i].id, label: forms[i].name));
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    String _studentName = "";
    String _className = "";

    const double padding = 16;

    return Scaffold(
      appBar: CliKASAAppBar(
        title: "Evaluierung",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
                "Die Evaluierungsbögen werden jeweils pro Schülerin und Schüler ausgeführt."),
            SizedBox(
              height: padding * 2,
            ),
            SizedBox(
              width: 400,
              child: Table(
                children: [
                  TableRow(children: [
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Text("Name Schüler/in:")),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: SizedBox(
                        width: 250,
                        child: TextField(
                          controller: TextEditingController(),
                          onChanged: (String newValue) {
                            _studentName = newValue;
                          },
                        ),
                      ),
                    ),
                  ]),
                  TableRow(children: [
                    TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Text("Klasse:")),
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: SizedBox(
                        width: 250,
                        child: TextField(
                          controller: TextEditingController(),
                          onChanged: (String newValue) {
                            _className = newValue;
                          },
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(
              height: padding * 2,
            ),
            FutureBuilder(
                future: _backendData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: padding),
                          Text("Daten werden geladen.")
                        ]);
                  }

                  if (snapshot.hasError) {
                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                              "Ein Fehler ist aufgetreten, die Daten wurden nicht geladen."),
                          const SizedBox(height: padding),
                          Text(snapshot.error.toString()),
                        ]);
                  }

                  if (!snapshot.hasData) {
                    return const Text("Keine Daten erhalten.");
                  }

                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownMenu(
                          onSelected: (dynamic formId) {
                            setState(() {
                              _formId = formId as String;
                            });
                          },
                          width: 300,
                          dropdownMenuEntries:
                              itemGenerator(snapshot.data!.forms),
                          label: const Text(
                              "Wählen Sie einen Evaluierungsbogen aus."),
                        ),
                      ]);
                }),
            const SizedBox(height: padding),
            DropdownMenu<String>(
              initialSelection: _type,
              onSelected: (String? type) {
                setState(() {
                  _type = type!;
                });
              },
              width: 300,
              dropdownMenuEntries: [
                DropdownMenuEntry(value: "text", label: "Eingabefeld"),
                DropdownMenuEntry(
                    value: "Schieberegler", label: "Schieberegler"),
                DropdownMenuEntry(value: "Radiobutton", label: "Radiobutton"),
                DropdownMenuEntry(value: "Dropdown", label: "Dropdown"),
                DropdownMenuEntry(value: "Sterne", label: "Sterne"),
                DropdownMenuEntry(value: "Smileys", label: "Smileys"),
              ],
              label: const Text("InputControls."),
            ),
            const SizedBox(height: padding),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EvaluationPage(
                          formId: _formId,
                          type: _type,
                          studentName:
                              _studentName.isNotEmpty ? _studentName : null,
                          className:
                              _className.isNotEmpty ? _className : null)));
                },
                child: const Text("Evaluierung starten")),
          ]),
        ),
      ),
    );
  }
}
