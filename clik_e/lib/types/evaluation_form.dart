import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat("dd.MM.yyyy HH:mm");

class Section {
  Section(this.label, this.questions);

  String label;
  List<String> questions;

  factory Section.fromJson(dynamic parsedData) {
    String label = parsedData["label"];
    List<String> questions = List<String>.from(parsedData["questions"]);
    return Section(label, questions);
  }
}

class EvaluationForm extends DataObject {
  EvaluationForm(super.id, this.name, this.description, this.creationDate,
      this.modificationDate, this.sections, this.suggestions);

  String name;
  String description;
  final DateTime creationDate;
  final DateTime modificationDate;
  List<Section> sections;
  List<String> suggestions;

  factory EvaluationForm.fromJson(dynamic parsedData) {
    final String id = parsedData["id"];
    String name = parsedData["name"];
    String description = parsedData["description"];
    final DateTime creationDate = DateTime.parse((parsedData["creationDate"]));
    final DateTime modificationDate =
        DateTime.parse((parsedData["modificationDate"]));
    List<Section> sections = [];
    List<dynamic> parsedSections = parsedData["sections"];
    for (int i = 0; i < parsedSections.length; ++i) {
      sections.add(Section.fromJson(parsedSections[i]));
    }
    List<String> suggestions = List<String>.from(parsedData["suggestions"]);
    return EvaluationForm(id, name, description, creationDate, modificationDate,
        sections, suggestions);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      // "creationDate": creationDate,
      // "modificationDate": modificationDate,
      // "sections": sections,
      // "suggestions": suggestions,
    };
  }

  @override
  DataRow getDataRow(bool selected, Function onTap, int position) {
    void pressed() {
      onTap(position);
    }

    return DataRow(
        color:
            WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.lightBlue;
          }
          return null; // Use the default value.
        }),
        selected: selected,
        cells: [
          DataCell(Text(id), onTap: pressed),
          DataCell(
              Column(
                children: [Text(name), Text(description)],
              ),
              onTap: pressed),
          DataCell(
              Column(
                children: [
                  Text(formatter.format(creationDate)),
                  Text(formatter.format(modificationDate))
                ],
              ),
              onTap: pressed),
        ]);
  }

  @override
  List<DataColumn> getColumns() {
    return const [
      DataColumn(label: Text("ID")),
      DataColumn(label: Column(children: [Text("Name"), Text("Beschreibung")])),
      DataColumn(
          label: Column(children: [Text("Erstellt"), Text("Zuletzt geändert")]))
    ];
  }

  @override
  Widget getEditControls(
    Function updateView,
    Map<String, List<DataObject>> relatedObjects,
  ) {
    final TextEditingController idController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController creationDateController =
        TextEditingController();
    final TextEditingController modificationDateController =
        TextEditingController();
    idController.text = id;
    nameController.text = name;
    descriptionController.text = description;
    creationDateController.text = formatter.format(creationDate);
    modificationDateController.text = formatter.format(modificationDate);

    const double padding = 16;

    List<DropdownMenuEntry> allQuestions = [];
    Question question;

    for (int i = 0; i < relatedObjects["questions"]!.length; ++i) {
      question = relatedObjects["questions"]![i] as Question;
      allQuestions
          .add(DropdownMenuEntry(value: question.id, label: question.question));
    }

    Row createQuestion(
      String question,
      Function(String newQuestionId) onSelectQuestion,
      Function() onDeleteQuestion,
    ) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownMenu(
          dropdownMenuEntries: allQuestions,
          width: 500,
          label: const Text("Frage auswählen"),
          initialSelection: question,
          onSelected: (dynamic newQuestionId) {
            onSelectQuestion(newQuestionId as String);
          },
        ),
        SizedBox(
          width: padding,
        ),
        Tooltip(
          message: "Frage löschen",
          child: IconButton(
              onPressed: onDeleteQuestion, icon: Icon(Icons.delete_forever)),
        ),
      ]);
    }

    Container createSection(
      Section section,
      Function(String newValue) onChangeSectionName,
      Function() onDeleteSection,
      Function() onAddQuestion,
      Function(String newQuestionId, int questionIndex) onSelectQuestion,
      Function(int questionIndex) onDeleteQuestion,
    ) {
      final TextEditingController sectionController = TextEditingController();
      sectionController.text = section.label;

      List<Widget> generatedQuestions = [];
      for (int questionIndex = 0;
          questionIndex < section.questions.length;
          ++questionIndex) {
        generatedQuestions.add(createQuestion(section.questions[questionIndex],
            (String newQuestionId) {
          onSelectQuestion(newQuestionId, questionIndex);
        }, () {
          onDeleteQuestion(questionIndex);
        }));
        generatedQuestions.add(SizedBox(
          height: padding,
        ));
      }

      Column innerColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              Text("Guppenname:"),
              SizedBox(
                width: padding,
              ),
              SizedBox(
                  width: 250,
                  child: TextField(
                    controller: sectionController,
                    onChanged: onChangeSectionName,
                  ))
            ]),
            Tooltip(
              message: "Gruppe löschen",
              child: IconButton(
                  onPressed: onDeleteSection, icon: Icon(Icons.delete_forever)),
            ),
          ]),
          SizedBox(
            height: padding,
          ),
          Text("Fragen:"),
          SizedBox(
            height: padding,
          ),
        ],
      );

      innerColumn.children.addAll(generatedQuestions);
      innerColumn.children.add(ElevatedButton(
          onPressed: onAddQuestion, child: const Text("Frage hinzufügen")));

      return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: padding / 2,
            vertical: padding / 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black),
          ),
          width: 650,
          child: innerColumn);
    }

    List<Widget> generatedSections = [];
    for (int sectionIndex = 0; sectionIndex < sections.length; ++sectionIndex) {
      generatedSections
          .add(createSection(sections[sectionIndex], (String newValue) {
        sections[sectionIndex].label = newValue;
      }, () {
        sections.remove(sections[sectionIndex]);
        updateView();
      }, () {
        sections[sectionIndex].questions.add("");
        updateView();
      }, (String newQuestionId, int questionIndex) {
        sections[sectionIndex].questions[questionIndex] = newQuestionId;
      }, (int questionIndex) {
        sections[sectionIndex]
            .questions
            .remove(sections[sectionIndex].questions[questionIndex]);
        updateView();
      }));
      generatedSections.add(SizedBox(
        height: padding,
      ));
    }

    generatedSections.add(ElevatedButton(
        onPressed: () {
          sections.add(Section("", []));
          updateView();
        },
        child: const Text("Gruppe hinzufügen")));

    List<DropdownMenuEntry> allSuggestions = [];
    List<DropdownMenuEntry> openSuggestions = [];

    Suggestion suggestion;
    for (int i = 0; i < relatedObjects["suggestions"]!.length; ++i) {
      suggestion = relatedObjects["suggestions"]![i] as Suggestion;
      if (!suggestions.contains(suggestion.id)) {
        openSuggestions.add(
            DropdownMenuEntry(value: suggestion.id, label: suggestion.name));
      }
      allSuggestions
          .add(DropdownMenuEntry(value: suggestion.id, label: suggestion.name));
    }

    Row createSuggestion(
      String suggestion,
      Function(String newValue) onSelectSuggestion,
      Function() onDeleteSuggestion,
    ) {
      List<DropdownMenuEntry> limitedSuggestions = [];

      limitedSuggestions
          .add(allSuggestions.firstWhere((DropdownMenuEntry dropDownItem) {
        return dropDownItem.value == suggestion;
      }));
      limitedSuggestions.addAll(openSuggestions);

      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropdownMenu(
          dropdownMenuEntries: limitedSuggestions,
          width: 500,
          label: const Text("Vorschlag auswählen"),
          initialSelection: suggestion,
          onSelected: (dynamic newValue) {
            onSelectSuggestion(newValue as String);
          },
        ),
        SizedBox(
          width: padding,
        ),
        Tooltip(
          message: "Vorschlag löschen",
          child: IconButton(
              onPressed: onDeleteSuggestion, icon: Icon(Icons.delete_forever)),
        ),
      ]);
    }

    Column suggestionColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [],
    );

    for (int suggestionIndex = 0;
        suggestionIndex < suggestions.length;
        ++suggestionIndex) {
      suggestionColumn.children.add(
          createSuggestion(suggestions[suggestionIndex], (String newValue) {
        suggestions[suggestionIndex] = newValue;
        updateView();
      }, () {
        suggestions.remove(suggestions[suggestionIndex]);
        updateView();
      }));
      suggestionColumn.children.add(SizedBox(
        height: padding,
      ));
    }

    if (openSuggestions.isNotEmpty) {
      suggestionColumn.children.add(ElevatedButton(
          onPressed: () {
            suggestions.add(openSuggestions[0].value);
            updateView();
          },
          child: const Text("Vorschlag hinzufügen")));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("ID"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: idController,
          enabled: false,
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Name"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: nameController,
          onChanged: (String newValue) {
            name = newValue;
          },
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Beschreibung"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: descriptionController,
          onChanged: (String newValue) {
            description = newValue;
          },
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Erstellt"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: creationDateController,
          enabled: false,
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Zuletzt geändert"),
      const SizedBox(
        height: padding / 2,
      ),
      SizedBox(
        width: 500,
        child: TextField(
          controller: modificationDateController,
          enabled: false,
        ),
      ),
      const SizedBox(
        height: padding,
      ),
      const Text("Layout"),
      const SizedBox(
        height: padding / 2,
      ),
      Column(children: generatedSections),
      const SizedBox(
        height: padding,
      ),
      const Text("Vorschläge"),
      const SizedBox(
        height: padding / 2,
      ),
      suggestionColumn
    ]);
  }

  @override
  Future<Map<String, List<DataObject>>> getRelatedItems() async {
    List<Question> questions =
        await DataService<Question>().getItems("questions");
    List<Suggestion> suggestions =
        await DataService<Suggestion>().getItems("suggestions");
    return {"questions": questions, "suggestions": suggestions};
  }
}
