import 'dart:convert';
import 'dart:io';
import 'package:clik_e/types/data_object.dart';
import 'package:clik_e/types/evaluation_form.dart';
import 'package:clik_e/types/feature.dart';
import 'package:clik_e/types/logic.dart';
import 'package:clik_e/types/question.dart';
import 'package:clik_e/types/suggestion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

// const String urlEndPoint = "http://127.0.0.1:3000/api/";
final String urlEndPoint = "http://localhost:3000/api/";
final Encoding? encoding = Encoding.getByName("utf-8");
final Map<String, String> headers = {
  HttpHeaders.contentTypeHeader: "application/json",
  HttpHeaders.acceptHeader: '*',
};
bool noConnection = false;

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

  Future<bool> addItem(String objectType, T dataObject) async {
    // final response = await http.post(
    //   Uri.parse("${urlEndPoint}addItem"),
    //   headers: headers,
    //   body: json.encode({
    //     "objectType": objectType,
    //     "dataObject": dataObject.toJson(),
    //   }),
    //   encoding: encoding,
    // );
    String dataObjectString = json.encode(dataObject.toJson());
    final response = await http.get(Uri.parse(
        "${urlEndPoint}addItem?objectType=$objectType&dataObject=$dataObjectString"));

    return response.statusCode == 201;
  }

  Future<bool> changeItem(String objectType, T dataObject) async {
    // final response = await http.post(
    //   Uri.parse("${urlEndPoint}changeItem"),
    //   headers: headers,
    //   body: json.encode({
    //     "objectType": objectType,
    //     "dataObject": dataObject.toJson(),
    //   }),
    //   encoding: encoding,
    // );
    String dataObjectString = json.encode(dataObject.toJson());
    final response = await http.get(Uri.parse(
        "${urlEndPoint}changeItem?objectType=$objectType&dataObject=$dataObjectString"));

    return response.statusCode == 200;
  }

  Future<bool> removeItem(String objectType, String id) async {
    // final response = await http.post(
    //   Uri.parse("${urlEndPoint}removeItem"),
    //   headers: headers,
    //   body: json.encode({
    //     "objectType": objectType,
    //     "id": id,
    //   }),
    //   encoding: encoding,
    // );
    final response = await http.get(
        Uri.parse("${urlEndPoint}removeItem?objectType=$objectType&id=$id"));

    return response.statusCode == 200;
  }

  loadData(String objectType) async {
    String sRawData;
    if (noConnection) {
      sRawData =
          await rootBundle.loadString("lib/database/rawdata_$objectType.json");
    } else {
      try {
        final response = await http.get(Uri.parse("$urlEndPoint$objectType"));

        if (response.statusCode != 200) {
          debugPrint(
              "!!! Failed to load data from server! getting local data instead!");
          String resBody = response.body;
          int resStatusCode = response.statusCode;
          debugPrint("body: $resBody");
          debugPrint("statusCode: $resStatusCode");

          sRawData = await rootBundle
              .loadString("lib/database/rawdata_$objectType.json");
          noConnection = true;
        } else {
          sRawData = response.body;
        }
      } catch (exception) {
        debugPrint("exception: $exception");
        debugPrint(
            "!!! Failed to load data from server! getting local data instead!");
        sRawData = await rootBundle
            .loadString("lib/database/rawdata_$objectType.json");
        noConnection = true;
      }
    }

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
