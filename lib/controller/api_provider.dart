import 'package:flutter/material.dart';

class ApiProvider with ChangeNotifier {
  List<String> stories = [];
  String story = "";
  bool flag = false;
  int id = 0;
  String job = "";
  String image = "";

  void setStory(String story) {
    this.story = story;
    stories.add(story);
    notifyListeners();
  }
  void setFlag(bool flag) {
    this.flag = flag;
    notifyListeners();

  }
  void setId(int id) {
    this.id = id;
    notifyListeners();
  }

  void setJob(String job) {
    this.job = job;
    notifyListeners();
  }

  void setImage(String image) {
    this.image = image;
    notifyListeners();
  }
}
