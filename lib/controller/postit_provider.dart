import 'package:flutter/material.dart';

class PostitProvider with ChangeNotifier {
  int currentPage = 0;
  late Map<int, String> _texts = {
    0: "",
    1: "",
    2: "",
  };

  // Getter for the text map
  Map<int, String> get texts => _texts;

  // Get specific text for a given index
  String getText(int index) => _texts[index] ?? '';

  // Update text for a given index
  void updateText(int index, String text) {
    _texts[index] = text;
    notifyListeners();
  }

  // Clear all texts (if necessary)
  void clearTexts() {
    _texts = {
      0: "",
      1: "",
      2: "",
    };
    currentPage = 0;
    notifyListeners();
  }
}
