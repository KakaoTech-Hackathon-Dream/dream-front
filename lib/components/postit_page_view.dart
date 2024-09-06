import 'package:flutter/material.dart';
import '../components/postit_textfield.dart';

class PostItPageView extends StatelessWidget {
  final PageController pageController;
  final int itemCount;

  const PostItPageView({
    super.key,
    required this.pageController,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PageView.builder(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return PostItTextField(
            index: index,
          );
        },
      ),
    );
  }
}
