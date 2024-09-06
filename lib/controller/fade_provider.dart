import 'package:flutter/material.dart';

class FadeProvider with ChangeNotifier {
  bool _isFadingToWhite = false;
  double _whiteOpacity = 0.0;
  AnimationController? animationController; // Store AnimationController

  bool get isFadingToWhite => _isFadingToWhite;
  double get whiteOpacity => _whiteOpacity;

  void startFadingToWhite(AnimationController controller) {
    _isFadingToWhite = true;
    animationController = controller;
    notifyListeners();
  }

  void setWhiteOpacity(double value) {
    _whiteOpacity = value;
    notifyListeners();
  }

  void resetFading() {
    _isFadingToWhite = false;
    _whiteOpacity = 0.0;
    notifyListeners();
  }
}
