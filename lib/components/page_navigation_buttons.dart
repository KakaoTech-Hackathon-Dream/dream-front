import 'package:flutter/material.dart';

class PageNavigationButtons extends StatelessWidget {
  final VoidCallback onNextPage;
  final VoidCallback onPrevPage;
  final VoidCallback onLastPage;
  final bool showPrevButton;
  final bool isNextButtonEnabled;
  final bool isLastButtonEnabled;
  final String nextButtonText;

  const PageNavigationButtons({
    super.key,
    required this.onNextPage,
    required this.onPrevPage,
    required this.onLastPage,
    required this.showPrevButton,
    required this.isNextButtonEnabled,
    required this.isLastButtonEnabled,
    required this.nextButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showPrevButton)
          Row(
            children: [
              GestureDetector(
                onTap: onPrevPage,
                child: Opacity(
                  opacity: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.amber,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      child: Text(
                        "이전",
                        style: TextStyle(fontSize: 18, fontFamily: "Medium"),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
        GestureDetector(
          onTap: isNextButtonEnabled ? isLastButtonEnabled ? onLastPage : onNextPage : null,
          child: Opacity(
            opacity: isNextButtonEnabled ? 1 : 0.2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.amber,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                child: Text(
                  nextButtonText,
                  style: const TextStyle(fontSize: 18, fontFamily: "Medium"),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
