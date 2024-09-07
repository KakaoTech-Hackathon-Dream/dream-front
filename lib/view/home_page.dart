import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hackathon/controller/api_provider.dart';
import 'package:provider/provider.dart';
import '../components/butterfly_animation.dart';
import '../components/page_navigation_buttons.dart';
import '../components/postit_page_view.dart';
import '../controller/fade_provider.dart';
import '../controller/postit_provider.dart';
import 'drawing_page.dart';
import 'package:http/http.dart' as http;


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final http.Response response;

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
    final apiProvider = Provider.of<ApiProvider>(context);


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

    Future<void> lastPage() async {
      fadeProvider.startFadingToWhite(_animationController);
      _animationController.forward();

      try {
        response = await http.post(
        Uri.parse("http://ec2-3-38-111-246.ap-northeast-2.compute.amazonaws.com:8080/api/story"),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'job': postitProvider.texts[0],
          'text': postitProvider.texts[1],
        }));
        if (response.statusCode != 200) {
          print("Error response: ${response.body}");
        } else {
          // 한글을 UTF-8로 디코딩
          final decodedBody = utf8.decode(response.bodyBytes);
          print("success response: $decodedBody");

          // JSON 파싱
          var jsonResponse = jsonDecode(decodedBody);

          // JSON 파싱

          // 각 변수에 할당
          apiProvider.setStory(jsonResponse['story'] ?? "");
          apiProvider.setFlag(jsonResponse['flag'] ?? false);
          apiProvider.setId(jsonResponse['id'] ?? 0);
          apiProvider.setJob(postitProvider.texts[0] ?? "");

        }
      } catch (e) {
        print("Error: $e");
      }

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
