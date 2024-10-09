import 'package:clik_e/pages/evaluation_page2.dart';
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
  int _evalId = 1;
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
    const double padding = 15;

    return Scaffold(
      appBar: CliKASAAppBar(
        title: "Evaluierung",
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: FutureBuilder(
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
                          onSelected: (formId) {
                            setState(() {
                              _formId = formId;
                            });
                          },
                          width: 300,
                          dropdownMenuEntries:
                              itemGenerator(snapshot.data!.forms),
                          label: const Text(
                              "Wählen Sie einen Evaluierungsbogen aus."),
                        ),
                        const SizedBox(height: padding),
                        DropdownMenu(
                          initialSelection: _evalId,
                          onSelected: (int? evalId) {
                            setState(() {
                              _evalId = evalId!;
                            });
                          },
                          width: 300,
                          dropdownMenuEntries: [
                            DropdownMenuEntry(
                                value: 1, label: "Tabellarischer Fragebogen"),
                            DropdownMenuEntry(
                                value: 2, label: "Einzelne Fragen"),
                          ],
                          label: const Text("Art der Evaluation."),
                        ),
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
                            DropdownMenuEntry(
                                value: "text", label: "Eingabefeld"),
                            DropdownMenuEntry(
                                value: "Schieberegler", label: "Schieberegler"),
                            DropdownMenuEntry(
                                value: "Radiobutton", label: "Radiobutton"),
                            DropdownMenuEntry(
                                value: "Dropdown", label: "Dropdown"),
                            DropdownMenuEntry(value: "Sterne", label: "Sterne"),
                            DropdownMenuEntry(
                                value: "Smileys", label: "Smileys"),
                          ],
                          label: const Text("InputControls."),
                        ),
                        const SizedBox(height: padding),
                        ElevatedButton(
                            onPressed: _formId != ""
                                ? () {
                                    MaterialPageRoute mpr = MaterialPageRoute(
                                        builder: (context) => EvaluationPage(
                                            formId: _formId, type: _type));
                                    if (_evalId == 2) {
                                      mpr = MaterialPageRoute(
                                          builder: (context) => EvaluationPage2(
                                              formId: _formId, type: _type));
                                    }
                                    Navigator.of(context).push(mpr);
                                  }
                                : null,
                            child: const Text("Evaluierung starten")),
                      ]);
                }),
          ),
        ),
      ),
    );
  }
}
