import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/feature.dart';
import 'package:clik_e/types/logic.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:clik_e/services/data_provider_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

Future<BackendData> getBackendData(
    String viewName, bool newObject, String id) async {
  DataObject dataObject;

  if (newObject) {
    if (id == "") {
      // Create new Object
      dataObject = await getNewObject(viewName);
    } else {
      // Copy an Object
      dataObject = await getObjectCopy(viewName, id);
    }
  } else {
    // Edit an Object
    dataObject = await getDataObject(viewName, id);
  }
  Map<String, List<DataObject>> relatedObjects =
      await dataObject.getRelatedItems();

  return BackendData(dataObject, relatedObjects);
}

Future<DataObject> getDataObject(String viewName, String id) async {
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

  return await dataService.getItem(viewName, id);
}

Future<DataObject> getNewObject(String viewName) async {
  String newId = uuid.v1();
  DataObject newObject = DataObject(newId);

  if (viewName == "forms") {
    newObject =
        EvaluationForm(newId, "", "", DateTime.now(), DateTime.now(), [], []);
  } else if (viewName == "questions") {
    newObject = Question(newId, "", "");
  } else if (viewName == "features") {
    newObject = Feature(newId, "");
  } else if (viewName == "suggestions") {
    newObject = Suggestion(newId, "", "", "", "", []);
  } else if (viewName == "logics") {
    newObject = Logic(newId, "", {});
  }

  return newObject;
}

Future<DataObject> getObjectCopy(String viewName, String id) async {
  String newId = uuid.v1();
  DataObject oldObject = await getDataObject(viewName, id);
  DataObject newObject = DataObject(newId);

  if (oldObject is EvaluationForm) {
    newObject = EvaluationForm(
        newId,
        oldObject.name,
        oldObject.description,
        DateTime.now(),
        DateTime.now(),
        oldObject.sections,
        oldObject.suggestions);
  } else if (oldObject is Question) {
    newObject = Question(newId, oldObject.question, oldObject.feature);
  } else if (oldObject is Feature) {
    newObject = Feature(newId, oldObject.name);
  } else if (oldObject is Suggestion) {
    newObject = Suggestion(
        newId,
        oldObject.name,
        oldObject.suggestionsInstructions,
        oldObject.expertExplanation,
        oldObject.expertReasoning,
        oldObject.connectedLogics);
  } else if (oldObject is Logic) {
    newObject = Logic(newId, oldObject.name, oldObject.weightedFeatures);
  }

  return newObject;
}

class ConfigurationDetailPage extends StatefulWidget {
  const ConfigurationDetailPage(
      {super.key,
      required this.viewName,
      required this.entityId,
      required this.newObject});

  final String viewName;
  final String entityId;
  final bool newObject;

  @override
  State<ConfigurationDetailPage> createState() =>
      _ConfigurationDetailPageState();
}

class BackendData {
  BackendData(this.dataObject, this.relatedObjects);

  DataObject dataObject;
  Map<String, List<DataObject>> relatedObjects;
}

class _ConfigurationDetailPageState extends State<ConfigurationDetailPage> {
  late Future<BackendData> _backendData;

  @override
  void initState() {
    super.initState();
    _backendData =
        getBackendData(widget.viewName, widget.newObject, widget.entityId);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 16;

    return Scaffold(
      appBar: CliKASAAppBar(
        title: widget.entityId,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder(
              future: _backendData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        CircularProgressIndicator(),
                        SizedBox(height: padding),
                        Text("Eintrag wird geladen.")
                      ]));
                }

                if (snapshot.hasError) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                            "Ein Fehler ist aufgetreten, der Eintrag konnte nicht geladen werden."),
                        const SizedBox(height: padding),
                        Text(snapshot.error.toString()),
                      ]);
                }

                if (!snapshot.hasData) {
                  return const Text("Eintrag nicht gefunden.");
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      snapshot.data!.dataObject.getEditControls(
                        () {
                          setState(() {});
                        },
                        snapshot.data!.relatedObjects,
                      ),
                      const SizedBox(height: padding),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Speichern")),
                            const SizedBox(width: padding),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Abbrechen"))
                          ])
                    ]);
              }),
        ),
      ),
    );
  }
}
