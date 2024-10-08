import 'package:clik_e/pages/analyze_page.dart';
import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/widgets/clik_appbar.dart';
import 'package:clik_e/widgets/menu_option.dart';
import 'package:flutter/material.dart';

class EvaluationPage extends StatefulWidget {
  const EvaluationPage({super.key, required this.formId, required this.type});

  final String formId;
  final String type;

  @override
  State<EvaluationPage> createState() => _EvaluationPageState();
}

class BackendData {
  const BackendData(
    this.form,
    this.questionMap,
  );

  final EvaluationForm form;
  final Map<String, Question> questionMap;
}

Future<BackendData> getBackendData(String formId) async {
  DataService<EvaluationForm> formsService = DataService<EvaluationForm>();
  DataService<Question> questionService = DataService<Question>();
  EvaluationForm form = await formsService.getItem("forms", formId);
  Map<String, Question> questionMap = {};

  for (int sectionIndex = 0;
      sectionIndex < form.sections.length;
      ++sectionIndex) {
    for (int questionIndex = 0;
        questionIndex < form.sections[sectionIndex].questions.length;
        ++questionIndex) {
      questionMap[form.sections[sectionIndex].questions[questionIndex]] =
          await questionService.getItem("questions",
              form.sections[sectionIndex].questions[questionIndex]);
    }
  }

  return BackendData(form, questionMap);
}

class _EvaluationPageState extends State<EvaluationPage> {
  late Future<BackendData> _backendData;

  @override
  void initState() {
    super.initState();
    _backendData = getBackendData(widget.formId);
  }

  double _currentSliderValue = 3;

  Column sectionGenerator(
      Section section,
      Map<String, Question> questionMap,
      String type,
      Function(double value) sliderChange,
      Function(double? value) radioChange,
      sliderValue) {
    List<Widget> children = [
      Text(section.label,
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
      const SizedBox(height: 16)
    ];

    for (int i = 0; i < section.questions.length; ++i) {
      children.add(questionGenerator(questionMap[section.questions[i]]!,
          widget.type, sliderChange, radioChange, _currentSliderValue));
    }

    children.add(const SizedBox(height: 16));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  Row questionGenerator(
      Question question,
      String type,
      Function(double value) sliderChange,
      Function(double? value) radioChange,
      sliderValue) {
    Widget InputControls = SizedBox(height: 32, width: 150, child: TextField());

    if (type == "Schieberegler") {
      InputControls = Slider(
          onChanged: sliderChange,
          value: sliderValue,
          min: 1,
          max: 6,
          divisions: 6,
          label: sliderValue.round().toString());
    } else if (type == "Radiobutton") {
      InputControls = Row(
        children: [
          Radio<double>(
            value: 1,
            groupValue: sliderValue,
            onChanged: radioChange,
          ),
          const Text("1"),
          Radio<double>(
            value: 2,
            groupValue: sliderValue,
            onChanged: radioChange,
          ),
          const Text("2"),
          Radio<double>(
            value: 3,
            groupValue: sliderValue,
            onChanged: radioChange,
          ),
          const Text("3"),
          Radio<double>(
            value: 4,
            groupValue: sliderValue,
            onChanged: radioChange,
          ),
          const Text("4"),
          Radio<double>(
            value: 5,
            groupValue: sliderValue,
            onChanged: radioChange,
          ),
          const Text("5"),
          Radio<double>(
            value: 6,
            groupValue: sliderValue,
            onChanged: radioChange,
          ),
          const Text("6"),
        ],
      );
    } else if (type == "Dropdown") {
      InputControls = DropdownMenu(
        dropdownMenuEntries: [
          DropdownMenuEntry(value: 1, label: "1"),
          DropdownMenuEntry(value: 2, label: "2"),
          DropdownMenuEntry(value: 3, label: "3"),
          DropdownMenuEntry(value: 4, label: "4"),
          DropdownMenuEntry(value: 5, label: "5"),
          DropdownMenuEntry(value: 6, label: "6"),
        ],
      );
    } else if (type == "Sterne") {
      InputControls = Row(
        children: [
          IconButton(
            icon: sliderValue >= 1
                ? Icon(Icons.star, color: Colors.amber.shade100)
                : Icon(Icons.star_border),
            onPressed: () {
              sliderChange(1);
            },
          ),
          IconButton(
            icon: sliderValue >= 2
                ? Icon(Icons.star, color: Colors.amber.shade200)
                : Icon(Icons.star_border),
            onPressed: () {
              sliderChange(2);
            },
          ),
          IconButton(
            icon: sliderValue >= 3
                ? Icon(Icons.star, color: Colors.amber.shade300)
                : Icon(Icons.star_border),
            onPressed: () {
              sliderChange(3);
            },
          ),
          IconButton(
            icon: sliderValue >= 4
                ? Icon(Icons.star, color: Colors.amber.shade400)
                : Icon(Icons.star_border),
            onPressed: () {
              sliderChange(4);
            },
          ),
          IconButton(
            icon: sliderValue >= 5
                ? Icon(Icons.star, color: Colors.amber.shade500)
                : Icon(Icons.star_border),
            onPressed: () {
              sliderChange(5);
            },
          ),
          IconButton(
            icon: sliderValue == 6
                ? Icon(Icons.star, color: Colors.amber.shade600)
                : Icon(Icons.star_border),
            onPressed: () {
              sliderChange(6);
            },
          ),
        ],
      );
    } else if (type == "Smileys") {
      InputControls = Row(
        children: [
          IconButton(
            icon: sliderValue >= 1
                ? Icon(Icons.tag_faces_rounded, color: Colors.amber.shade100)
                : Icon(Icons.tag_faces_outlined),
            onPressed: () {
              sliderChange(1);
            },
          ),
          IconButton(
            icon: sliderValue >= 2
                ? Icon(Icons.tag_faces_rounded, color: Colors.amber.shade200)
                : Icon(Icons.tag_faces_outlined),
            onPressed: () {
              sliderChange(2);
            },
          ),
          IconButton(
            icon: sliderValue >= 3
                ? Icon(Icons.tag_faces_rounded, color: Colors.amber.shade300)
                : Icon(Icons.tag_faces_outlined),
            onPressed: () {
              sliderChange(3);
            },
          ),
          IconButton(
            icon: sliderValue >= 4
                ? Icon(Icons.tag_faces_rounded, color: Colors.amber.shade400)
                : Icon(Icons.tag_faces_outlined),
            onPressed: () {
              sliderChange(4);
            },
          ),
          IconButton(
            icon: sliderValue >= 5
                ? Icon(Icons.tag_faces_rounded, color: Colors.amber.shade500)
                : Icon(Icons.tag_faces_outlined),
            onPressed: () {
              sliderChange(5);
            },
          ),
          IconButton(
            icon: sliderValue == 6
                ? Icon(Icons.tag_faces_rounded, color: Colors.amber.shade600)
                : Icon(Icons.tag_faces_outlined),
            onPressed: () {
              sliderChange(6);
            },
          ),
        ],
      );
    }

    return Row(children: [
      SizedBox(width: 600, child: Text(question.question)),
      const SizedBox(width: 16),
      InputControls,
      const SizedBox(height: 16),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 15;

    void valueChange(double value) {
      setState(() {
        _currentSliderValue = value;
      });
    }

    void radioChange(double? value) {
      setState(() {
        _currentSliderValue = value!;
      });
    }

    return Scaffold(
      appBar: ClikAppBar(
        title: "Evaluierung",
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

                  return Column(children: [
                    Column(
                        children: snapshot.data!.form.sections
                            .map((section) => sectionGenerator(
                                section,
                                snapshot.data!.questionMap,
                                widget.type,
                                valueChange,
                                radioChange,
                                _currentSliderValue))
                            .toList()),
                    const SizedBox(height: padding),
                    SizedBox(
                        width: 250.0,
                        child: MenuOption(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const AnalyzePage(),
                                ),
                              );
                            },
                            text: "Auswertung",
                            icon: Icons.analytics))
                  ]);
                })
          ]),
        ),
      ),
    );
  }
}
