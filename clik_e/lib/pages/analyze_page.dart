import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/feature.dart';
import 'package:clik_e/types/logic.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:flutter/material.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key, required this.formId});

  final String formId;

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class BackendData {
  BackendData(
    this.form,
    this.featureMap,
    this.suggestionMap,
    this.logicMap,
  );

  EvaluationForm form;
  Map<String, Feature> featureMap;
  Map<String, Suggestion> suggestionMap;
  Map<String, Logic> logicMap;
}

Future<EvaluationForm> getEvaluationForm(String formId) async {
  DataService<EvaluationForm> formsService = DataService<EvaluationForm>();

  return await formsService.getItem("forms", formId);
}

Future<Map<String, Feature>> getFeatureMap(List<Section> sections) async {
  DataService<Question> questionService = DataService<Question>();
  DataService<Feature> featureService = DataService<Feature>();
  Section section;
  String questionId;
  Question question;
  Map<String, Feature> featureMap = {};

  for (int sectionIndex = 0; sectionIndex < sections.length; ++sectionIndex) {
    section = sections[sectionIndex];
    for (int questionIndex = 0;
        questionIndex < section.questions.length;
        ++questionIndex) {
      questionId = section.questions[questionIndex];
      question = await questionService.getItem("questions", questionId);
      if (!featureMap.keys.contains(question.feature)) {
        featureMap[question.feature] =
            await featureService.getItem("features", question.feature);
      }
    }
  }

  return featureMap;
}

Future<BackendData> getBackendData(String formId) async {
  EvaluationForm form = await getEvaluationForm(formId);
  Map<String, Feature> featureMap = await getFeatureMap(form.sections);

  DataService<Suggestion> suggestionService = DataService<Suggestion>();
  DataService<Logic> logicService = DataService<Logic>();
  String suggestionId;
  Suggestion suggestion;
  Map<String, Suggestion> suggestionMap = {};
  String logicId;
  Map<String, Logic> logicMap = {};

  for (int suggestionIndex = 0;
      suggestionIndex < form.suggestions.length;
      ++suggestionIndex) {
    suggestionId = form.suggestions[suggestionIndex];
    suggestion = await suggestionService.getItem("suggestions", suggestionId);
    suggestionMap[suggestionId] = suggestion;
    for (int logicIndex = 0;
        logicIndex < suggestion.connectedLogics.length;
        ++logicIndex) {
      logicId = suggestion.connectedLogics[logicIndex];
      logicMap[logicId] = await logicService.getItem("logics", logicId);
    }
  }

  return BackendData(form, featureMap, suggestionMap, logicMap);
}

class _AnalyzePageState extends State<AnalyzePage> {
  late Future<BackendData> _backendData;

  @override
  void initState() {
    super.initState();
    _backendData = getBackendData(widget.formId);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 16;

    return Scaffold(
      appBar: CliKASAAppBar(
        title: "Auswertung",
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            const SizedBox(height: padding),
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

                  return Column(children: [Text("Laden erfolgreich!")]);
                })
          ]),
        ),
      ),
    );
  }
}
