import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:paradox/models/hint.dart';
import 'package:paradox/models/question.dart';
import 'package:paradox/utilities/constant.dart';

class QuestionProvider extends ChangeNotifier {
  List<Question> _questionList = [];

  List<Question> get questionList {
    return [..._questionList];
  }

  List<Hint> _hintsList = [];

  List<Hint> get hintsList {
    return [..._hintsList];
  }

  void fetchQuestions() async {
    String url = "${baseUrl}questions/";
    Response response = await get(url);
    if (response.statusCode == 200) {
      _questionList.clear();
      var data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        _questionList.add(Question(
          level: data[i]['level'],
          location: data[i]['location'],
        ));
      }
      notifyListeners();
    } else {
      throw Exception();
    }
  }

  void fetchHints() async {
    String url = "${baseUrl}hints/";
    Response response = await get(url);
    if (response.statusCode == 200) {
      _questionList.clear();
      var data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        _hintsList.add(Hint(
          level: data[i]['level'],
          hint1: data[i]['hint1'],
          hint2: data[i]['hint2'],
          hint3: data[i]['hint3'],
        ));
      }
      notifyListeners();
    } else {
      throw Exception();
    }
  }
}
