import 'dart:async';
import 'package:flutter/material.dart';

class ButterflyAnimation extends StatefulWidget {
  const ButterflyAnimation({super.key});

  @override
  _ButterflyAnimationState createState() => _ButterflyAnimationState();
}

class _ButterflyAnimationState extends State<ButterflyAnimation> {
  double _butterflyXPosition = 0.0;
  double _butterflyYPosition = 0.0;
  double _butterflyScale = 0.8; // 나비 크기
  final double _speedX = 1.0;
  final double _speedY = 1.0;
  bool _isGettingCloser = true;

  @override
  void initState() {
    super.initState();
    _startFlying();
  }

  void _startFlying() {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _butterflyXPosition += _speedX;
        _butterflyYPosition += _speedY;

        if (_isGettingCloser) {
          _butterflyScale += 0.005;
          if (_butterflyScale >= 1.0) {
            _isGettingCloser = false;
          }
        } else {
          _butterflyScale -= 0.005;
          if (_butterflyScale <= 0.8) {
            _isGettingCloser = true;
          }
        }

        if (_butterflyXPosition > MediaQuery.of(context).size.width) {
          _butterflyXPosition = -50;
        }

        if (_butterflyYPosition > MediaQuery.of(context).size.height) {
          _butterflyYPosition = 0.0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _butterflyXPosition,
      top: _butterflyYPosition,
      child: Transform.scale(
        scale: _butterflyScale,
        child: Image.asset(
          "./assets/background/butterfly.png",
          scale: 10,
        ),
      ),
    );
  }
}
