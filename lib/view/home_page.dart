import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/butterfly_animation.dart';
import '../components/page_navigation_buttons.dart';
import '../components/postit_page_view.dart';
import '../controller/fade_provider.dart';
import '../controller/postit_provider.dart';
import 'drawing_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _fadeAnimation =
    Tween<double>(begin: 0.0, end: 0.99).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeProvider = Provider.of<FadeProvider>(context);
    final postitProvider = Provider.of<PostitProvider>(context);

    void nextPage() {
      if (postitProvider.currentPage < 2) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() {
          postitProvider.currentPage++;
        });
      }
    }

    void prevPage() {
      if (postitProvider.currentPage > 0) {
        _pageController.previousPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        setState(() {
          postitProvider.currentPage--;
        });
      }
    }

    void lastPage() {
      fadeProvider.startFadingToWhite(_animationController);
      _animationController.forward();
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        body: Stack(
          children: [
            Container(
              color: Theme.of(context).primaryColor,
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: Column(
                        children: [
                          Text(
                            "드림,",
                            style: TextStyle(
                                fontFamily: "Bold",
                                color: Colors.black,
                                fontSize: 40),
                          ),
                          Text(
                            "당신의 그리운 꿈을 드립니다.",
                            style: TextStyle(
                                fontFamily: "Light",
                                color: Colors.black,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    PostItPageView(
                      pageController: _pageController,
                      itemCount: 2,
                    ),
                    const SizedBox(height: 10),
                    PageNavigationButtons(
                      onNextPage: nextPage,
                      onLastPage: lastPage,
                      onPrevPage: prevPage,
                      showPrevButton: postitProvider.currentPage > 0,
                      isNextButtonEnabled:
                      postitProvider.texts[postitProvider.currentPage]!.isNotEmpty,
                      isLastButtonEnabled: postitProvider.currentPage == 1,
                      nextButtonText:
                      postitProvider.currentPage == 1 ? "책 펼치기" : "다음",
                    ),
                    Image.asset("./assets/background/flowers.png"),
                  ],
                ),
              ),
            ),
            const ButterflyAnimation(),
            if (fadeProvider.isFadingToWhite)
              Positioned.fill(
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    color: Colors.white,
                    child: DrawingPage(
                        pageController: _pageController
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
