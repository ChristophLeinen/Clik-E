import 'package:clik_e/pages/configuration_detail_page.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/feature.dart';
import 'package:clik_e/types/logic.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:clik_e/widgets/config_pagination_data_table.dart';
import 'package:clik_e/services/data_provider_service.dart';
import 'package:flutter/material.dart';

class ConfigurationOverviewPage extends StatefulWidget {
  const ConfigurationOverviewPage(
      {super.key, required this.viewName, required this.tableName});

  final String viewName;
  final String tableName;

  @override
  State<ConfigurationOverviewPage> createState() =>
      _ConfigurationOverviewPageState();
}

class BackendData {
  const BackendData(this.items);

  final List<DataObject> items;
}

class _ConfigurationOverviewPageState extends State<ConfigurationOverviewPage> {
  late Future<BackendData> _backendData;

  @override
  void initState() {
    super.initState();
    _backendData = getBackendData(widget.viewName);
  }

  DataService getDataService(String viewName) {
    DataService dataService = DataService<DataObject>();

    if (viewName == "forms") {
      dataService = DataService<EvaluationForm>();
    } else if (viewName == "questions") {
      dataService = DataService<Question>();
    } else if (viewName == "features") {
      dataService = DataService<Feature>();
    } else if (viewName == "suggestions") {
      dataService = DataService<Suggestion>();
    } else if (viewName == "logics") {
      dataService = DataService<Logic>();
    } else {
      dataService = DataService<DataObject>();
    }

    return dataService;
  }

  Future<BackendData> getBackendData(String viewName) async {
    DataService dataService = getDataService(viewName);
    List<DataObject> items = await dataService.getItems(viewName);
    return BackendData(items);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 16;

    return Scaffold(
      appBar: CliKASAAppBar(
        title: widget.tableName,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
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

                    return ConfigurationDataTable<DataObject>(
                      title: widget.tableName,
                      items: snapshot.data!.items,
                      onAddRow: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfigurationDetailPage(
                              viewName: widget.viewName,
                              entityId: "",
                              newObject: true,
                            ),
                          ),
                        );
                      },
                      onCopyRow: (int rowNumber) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfigurationDetailPage(
                              viewName: widget.viewName,
                              entityId: snapshot.data!.items[rowNumber].id,
                              newObject: true,
                            ),
                          ),
                        );
                      },
                      onDeleteRow: (int rowNumber) async {
                        DataService dataService =
                            getDataService(widget.viewName);
                        try {
                          await dataService.removeItem(widget.viewName,
                              snapshot.data!.items[rowNumber].id);
                          setState(() {});
                        } catch (exception) {
                          debugPrint("$exception");
                        }
                      },
                      onEditRow: (int rowNumber) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ConfigurationDetailPage(
                              viewName: widget.viewName,
                              entityId: snapshot.data!.items[rowNumber].id,
                              newObject: false,
                            ),
                          ),
                        );
                      },
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }
}
