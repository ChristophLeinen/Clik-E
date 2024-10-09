import 'dart:convert';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/feature.dart';
import 'package:clik_e/types/logic.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:flutter/services.dart';

class DataService<T extends DataObject> {
  Future<List<T>> getItems(String objectType) async {
    return await loadData(objectType);
  }

  Future<T> getItem(String objectType, String id) async {
    List<T> items = await getItems(objectType);

    for (int i = 0; i < items.length; ++i) {
      if (items[i].id == id) {
        return items[i];
      }
    }

    return items[-1];
  }

  loadData(String objectType) async {
    final String sRawData =
        await rootBundle.loadString("lib/database/rawdata_$objectType.json");

    final Map<String, dynamic> parsedJson = json.decode(sRawData);
    final parsedItems = List<dynamic>.from(parsedJson["items"]);

    List<T> items = [];

    for (int i = 0; i < parsedItems.length; ++i) {
      if (objectType == "forms") {
        items.add(EvaluationForm.fromJson(parsedItems[i]) as T);
      } else if (objectType == "questions") {
        items.add(Question.fromJson(parsedItems[i]) as T);
      } else if (objectType == "features") {
        items.add(Feature.fromJson(parsedItems[i]) as T);
      } else if (objectType == "suggestions") {
        items.add(Suggestion.fromJson(parsedItems[i]) as T);
      } else if (objectType == "logics") {
        items.add(Logic.fromJson(parsedItems[i]) as T);
      } else {
        items.add(DataObject.fromJson(parsedItems[i]) as T);
      }
    }

    return items;
  }
}
