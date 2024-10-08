import 'package:clik_e/services/data_provider_service.dart';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final DateFormat formatter = DateFormat("dd.MM.yyyy HH:mm");

class Section {
  const Section(this.label, this.questions);

  final String label;
  final List<String> questions;

  factory Section.fromJson(dynamic parsedData) {
    final label = parsedData["label"] as String;
    final questions = List<String>.from(parsedData["questions"]);
    return Section(label, questions);
  }
}

class EvaluationForm extends DataObject {
  const EvaluationForm(id, this.name, this.description, this.creationDate,
      this.modificationDate, this.sections, this.suggestions)
      : super(id);

  final String name;
  final String description;
  final DateTime creationDate;
  final DateTime modificationDate;
  final List<Section> sections;
  final List<String> suggestions;

  factory EvaluationForm.fromJson(dynamic parsedData) {
    final id = parsedData["id"] as String;
    final name = parsedData["name"] as String;
    final description = parsedData["description"] as String;
    final creationDate = DateTime.parse((parsedData["creationDate"]));
    final modificationDate = DateTime.parse((parsedData["modificationDate"]));
    List<Section> sections = [];
    final parsedSections = parsedData["sections"];
    for (var i = 0; i < parsedSections.length; ++i) {
      sections.add(Section.fromJson(parsedSections[i]));
    }
    final suggestions = List<String>.from(parsedData["suggestions"]);
    return EvaluationForm(id, name, description, creationDate, modificationDate,
        sections, suggestions);
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
  Widget getEditControls() {
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

    Future<List<Question>> getAllQuestions() async {
      return await DataService<Question>().getItems("questions");
    }

    Future<List<Suggestion>> getAllSuggestions() async {
      return await DataService<Suggestion>().getItems("suggestions");
    }

    const double padding = 16;

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
      FutureBuilder(
          future: getAllQuestions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text("Fragen konnten nicht geladen werden.");
            }

            List<DropdownMenuEntry> allQuestions = [];

            for (int i = 0; i < snapshot.data!.length; ++i) {
              allQuestions.add(DropdownMenuEntry(
                  value: snapshot.data![i].id,
                  label: snapshot.data![i].question));
            }

            Row createQuestion(String question) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu(
                      dropdownMenuEntries: allQuestions,
                      width: 500,
                      label: const Text("Frage auswählen"),
                      initialSelection: question,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Tooltip(
                      message: "Frage löschen",
                      child: IconButton(
                          onPressed: () {}, icon: Icon(Icons.delete_forever)),
                    ),
                  ]);
            }

            Container createSection(Section section) {
              final TextEditingController sectionController =
                  TextEditingController();
              sectionController.text = section.label;

              List<Widget> generatedQuestions = [];
              for (var questionIndex = 0;
                  questionIndex < section.questions.length;
                  ++questionIndex) {
                generatedQuestions
                    .add(createQuestion(section.questions[questionIndex]));
                generatedQuestions.add(SizedBox(
                  height: padding,
                ));
              }

              Column innerColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [
                          Text("Guppenname:"),
                          SizedBox(
                            width: padding,
                          ),
                          SizedBox(
                              width: 250,
                              child: TextField(
                                controller: sectionController,
                              ))
                        ]),
                        Tooltip(
                          message: "Gruppe löschen",
                          child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.delete_forever)),
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
                  onPressed: () {}, child: const Text("Frage hinzufügen")));

              return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: padding / 2,
                    vertical: padding / 2,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  width: 800,
                  child: innerColumn);
            }

            List<Widget> generatedSections = [];
            for (var sectionIndex = 0;
                sectionIndex < sections.length;
                ++sectionIndex) {
              generatedSections.add(createSection(sections[sectionIndex]));
              generatedSections.add(SizedBox(
                height: padding,
              ));
            }

            generatedSections.add(ElevatedButton(
                onPressed: () {}, child: const Text("Gruppe hinzufügen")));

            return Column(children: generatedSections);
          }),
      const SizedBox(
        height: padding,
      ),
      const Text("Vorschläge"),
      const SizedBox(
        height: padding / 2,
      ),
      FutureBuilder(
          future: getAllSuggestions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Text("Vorschläge konnten nicht geladen werden.");
            }

            List<DropdownMenuEntry> allSuggestion = [];

            for (int i = 0; i < snapshot.data!.length; ++i) {
              allSuggestion.add(DropdownMenuEntry(
                  value: snapshot.data![i].id, label: snapshot.data![i].name));
            }

            Row createSuggestion(String suggestion) {
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownMenu(
                      dropdownMenuEntries: allSuggestion,
                      width: 500,
                      label: const Text("Vorschlag auswählen"),
                      initialSelection: suggestion,
                    ),
                    SizedBox(
                      width: padding,
                    ),
                    Tooltip(
                      message: "Vorschlag löschen",
                      child: IconButton(
                          onPressed: () {}, icon: Icon(Icons.delete_forever)),
                    ),
                  ]);
            }

            Column innerSuggestionColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [],
            );

            for (var suggestionIndex = 0;
                suggestionIndex < suggestions.length;
                ++suggestionIndex) {
              innerSuggestionColumn.children
                  .add(createSuggestion(suggestions[suggestionIndex]));
              innerSuggestionColumn.children.add(SizedBox(
                height: padding,
              ));
            }

            innerSuggestionColumn.children.add(ElevatedButton(
                onPressed: () {}, child: const Text("Vorschlag hinzufügen")));

            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: padding / 2,
                vertical: padding / 2,
              ),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Colors.black),
              ),
              width: 800,
              child: innerSuggestionColumn,
            );
          }),
    ]);
  }
}
