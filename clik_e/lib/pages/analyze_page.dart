import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/feature.dart';
import 'package:clik_e/types/logic.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:flutter/material.dart';
import 'package:spider_chart/spider_chart.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage(
      {super.key,
      required this.formId,
      required this.questionAnswerMap,
      this.studentName,
      this.className});

  final String formId;
  final Map<String, int> questionAnswerMap;
  final String? studentName;
  final String? className;

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class BackendData {
  BackendData(
    this.form,
    this.featureCountMap,
    this.featureMap,
    this.featureSumMap,
    this.suggestionMap,
    this.logicMap,
  );

  EvaluationForm form;
  Map<String, int> featureCountMap;
  Map<String, Feature> featureMap;
  Map<String, int> featureSumMap;
  Map<String, Suggestion> suggestionMap;
  Map<String, Logic> logicMap;
}

Future<EvaluationForm> getEvaluationForm(String formId) async {
  DataService<EvaluationForm> formsService = DataService<EvaluationForm>();

  return await formsService.getItem("forms", formId);
}

Future<BackendData> getBackendData(
    String formId, Map<String, int> questionAnswerMap) async {
  EvaluationForm form = await getEvaluationForm(formId);

  DataService<Question> questionService = DataService<Question>();
  DataService<Feature> featureService = DataService<Feature>();
  Section section;
  String questionId;
  Question question;
  Map<String, int> featureCountMap = {};
  Map<String, Feature> featureMap = {};
  Map<String, int> featureSumMap = {};

  for (int sectionIndex = 0;
      sectionIndex < form.sections.length;
      ++sectionIndex) {
    section = form.sections[sectionIndex];
    for (int questionIndex = 0;
        questionIndex < section.questions.length;
        ++questionIndex) {
      questionId = section.questions[questionIndex];

      if (!questionAnswerMap.containsKey(questionId)) {
        // Question was not answered
        continue;
      }

      question = await questionService.getItem("questions", questionId);

      if (!featureMap.keys.contains(question.feature)) {
        featureMap[question.feature] =
            await featureService.getItem("features", question.feature);
        featureCountMap[question.feature] = 1;
        featureSumMap[question.feature] = questionAnswerMap[questionId]!;
      } else {
        featureCountMap[question.feature] =
            featureCountMap[question.feature]! + 1;
        featureSumMap[question.feature] =
            featureSumMap[question.feature]! + questionAnswerMap[questionId]!;
      }
    }
  }

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

  return BackendData(form, featureCountMap, featureMap, featureSumMap,
      suggestionMap, logicMap);
}

class _AnalyzePageState extends State<AnalyzePage> {
  late Future<BackendData> _backendData;

  @override
  void initState() {
    super.initState();
    _backendData = getBackendData(widget.formId, widget.questionAnswerMap);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 16;

    String title = "Auswertung";
    String? studentName = widget.studentName;
    String? className = widget.className;
    if (studentName != null) {
      if (className != null) {
        title = "Auswertung von $studentName, $className";
      } else {
        title = "Auswertung von $studentName";
      }
    }

    return Scaffold(
      appBar: CliKASAAppBar(
        title: title,
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
                            SizedBox(height: padding),
                            CircularProgressIndicator(),
                            SizedBox(height: padding),
                            Text("Daten werden geladen.")
                          ]);
                    }

                    if (snapshot.hasError) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: padding),
                            const Text(
                                "Ein Fehler ist aufgetreten, die Daten wurden nicht geladen."),
                            const SizedBox(height: padding),
                            Text(snapshot.error.toString()),
                          ]);
                    }

                    if (!snapshot.hasData) {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: padding),
                            const Text("Keine Daten erhalten.")
                          ]);
                    }

                    Map<String, Feature> featureMap = snapshot.data!.featureMap;
                    Map<String, int> featureSumMap =
                        snapshot.data!.featureSumMap;
                    Map<String, int> featureCountMap =
                        snapshot.data!.featureCountMap;

                    List<TableRow> tablesRows = [
                      TableRow(children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Text("Kategorie und Eigenschaft"),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Center(
                              child: Text("Anzahl Items"),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Center(
                              child: Text("Summe"),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Center(
                              child: Text("Mittelwert"),
                            ),
                          ),
                        ),
                      ]),
                    ];

                    List<double> spiderData = [];
                    List<String> spiderLabels = [];
                    List<Color> spiderColors = [];
                    String featureName;
                    int featureCount;
                    int featureSum;
                    double featureAverage;
                    for (String key in featureMap.keys) {
                      featureCount = featureCountMap[key]!;
                      featureSum = featureSumMap[key]!;
                      featureAverage = featureSum / featureCount;
                      featureName = featureMap[key]!
                          .name
                          .replaceAll(", ", ",\n")
                          .replaceAll("und ", "und\n");
                      spiderData.add(featureAverage / 6);
                      spiderLabels.add(featureName);
                      spiderColors.add(Colors.black);
                      tablesRows.add(TableRow(children: [
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Text(featureName),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Center(
                              child: Text("$featureCount"),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Center(
                              child: Text("$featureSum"),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding / 2,
                              vertical: padding / 2,
                            ),
                            child: Center(
                              child:
                                  Text(featureAverage.toStringAsPrecision(3)),
                            ),
                          ),
                        ),
                      ]));
                    }

                    return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: padding),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding,
                              vertical: padding,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.lightBlue[100],
                                borderRadius: BorderRadius.circular(padding)),
                            width: 650,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Handlungsempfehlungen:"),
                                SizedBox(
                                  height: padding,
                                ),
                                Text("1. blablabla (70%)"),
                                Text(
                                    "Der Schüler, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                                Text("2. fapojpajaw (40%)"),
                                Text(
                                    "Der Schüler, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                                Text("3. afawf afaf aofpkpawfa (20%)"),
                                Text(
                                    "Der Schüler, Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: padding,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: padding,
                              vertical: padding,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(padding)),
                            width: 650,
                            child: Table(
                              columnWidths: const {
                                1: FixedColumnWidth(160),
                                2: FixedColumnWidth(70),
                                3: FixedColumnWidth(90)
                              },
                              border: TableBorder.all(),
                              children: tablesRows,
                            ),
                          ),
                          SizedBox(
                            height: padding,
                          ),
                          SizedBox(
                            width: 650,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text("Netzdiagramm der Dimensionen"),
                                ),
                                SizedBox(
                                  height: padding,
                                ),
                                Center(
                                  child: SizedBox(
                                    width: 250,
                                    height: 250,
                                    child: SpiderChart(
                                      decimalPrecision: 2,
                                      data: spiderData,
                                      maxValue: 1,
                                      labels: spiderLabels,
                                      colors: spiderColors,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: padding,
                          ),
                        ]);
                  })),
        ),
      ),
    );
  }
}
