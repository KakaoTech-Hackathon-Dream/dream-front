import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hackathon/controller/api_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../components/turn_page_view.dart';
import '../controller/fade_provider.dart';
import '../controller/postit_provider.dart';
import 'package:flutter/cupertino.dart';

class DrawingPage extends StatefulWidget {
  final PageController pageController;

  const DrawingPage({
    super.key,
    required this.pageController,
  });

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with TickerProviderStateMixin {
  late TurnPageController _controller;
  int curPage = 0;
  UniqueKey animatedTextKey = UniqueKey();
  late ScrollController _scrollController;
  bool textAnimation = true;
  double _bookOpacity = 1.0; // Book()의 투명도 관리
  double _pictureOpacity = 0.0; // Picture()의 투명도 관리
  bool flag = false;
  int id = 0;
  String image = "./assets/background/ai.png";

  @override
  void initState() {
    super.initState();
    _controller = TurnPageController(
        initialPage: 0, duration: const Duration(seconds: 2));
    _controller.initAnimation(this, 4);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateText(int nextPage) {
    setState(() {
      curPage = nextPage;
      animatedTextKey = UniqueKey();
    });
    //
    // // 텍스트가 업데이트될 때마다 스크롤을 아래로 이동
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _scrollToBottom();
    // });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScrollPosition = _scrollController.position.pixels;
      // 현재 스크롤 위치가 맨 아래가 아닐 경우에만 스크롤을 맨 아래로 보냄
      if (currentScrollPosition < maxScrollExtent) {
        _scrollController.animateTo(
          maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  Future<void> _downloadImage() async {
    final status = await Permission.storage.request(); // 저장소 권한 요청
    if (status.isGranted) {
      try {
        String url = 'assets/background/ai.png'; // 로컬 이미지 경로
        ByteData data = await rootBundle.load(url); // 로컬 이미지 로드
        List<int> bytes = data.buffer.asUint8List();

        // 갤러리에 저장
        final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(bytes),
          quality: 100,
          name: "ai_image", // 저장될 파일명
        );

        if (result['isSuccess']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지가 갤러리에 저장되었습니다')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('이미지 저장에 실패했습니다')),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이미지 저장 중 오류가 발생했습니다')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장소 접근 권한이 없습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final fadeProvider = Provider.of<FadeProvider>(context, listen: false);
    final postitProvider = Provider.of<PostitProvider>(context, listen: false);
    final apiProvider = Provider.of<ApiProvider>(context, listen: false);

    final AnimationController animationController =
        fadeProvider.animationController!;
    if (textAnimation) {
      _scrollToBottom();
    }

    void deskOut() {
      postitProvider.clearTexts();
      widget.pageController.jumpToPage(0);
      // _controller.jumpToPage(0);
      animationController.reverse().then((_) {
        fadeProvider.resetFading();
      });
    }

    String desc = _pictureOpacity != 1 ? "이야기를 볼 수 없습니다" : "사진을 볼 수 없습니다";

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("./assets/background/desk.png"),
        ),
      ),
      child: Stack(
        children: [
          SafeArea(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                scrolledUnderElevation: 0,
                backgroundColor: Colors.transparent,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              child: AlertDialog(
                                title: const Text(
                                  "정말 그만 보시겠습니까?",
                                  style: TextStyle(
                                      fontFamily: "Bold", fontSize: 23),
                                ),
                                content: Text(
                                  "더 이상 ${desc}!",
                                  style: const TextStyle(fontFamily: "Light"),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                      "아니오",
                                      style: TextStyle(
                                          fontFamily: "Writing", fontSize: 25),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // AlertDialog 닫기
                                    },
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  TextButton(
                                    child: const Text(
                                      "네",
                                      style: TextStyle(
                                          fontFamily: "Writing", fontSize: 25),
                                    ),
                                    onPressed: () async {
                                      if (_pictureOpacity == 1) {
                                        deskOut();
                                        setState(() {
                                          _bookOpacity = 1.0;
                                          _pictureOpacity = 0.0;
                                        });
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          _bookOpacity = 0.0;
                                          _pictureOpacity = 1.0;
                                        });
                                        try {
                                          final http.Response response =
                                              await http.post(
                                            Uri.parse(
                                                "http://ec2-3-38-111-246.ap-northeast-2.compute.amazonaws.com:8000/api/image"),
                                            headers: <String, String>{
                                              'Content-Type':
                                                  'application/json',
                                            },
                                            body:
                                                jsonEncode({'job': apiProvider.job}),
                                          );
                                          if (response.statusCode != 200) {
                                            print(
                                                "Error response: ${response.body}");
                                          } else {
                                            final decodedBody =
                                                utf8.decode(response.bodyBytes);
                                            print(
                                                "success response: $decodedBody");

                                            // JSON 파싱
                                            var jsonResponse =
                                                jsonDecode(decodedBody);

                                            // JSON 파싱

                                            // 각 변수에 할당
                                            apiProvider.setImage(jsonResponse['image_url'] ?? image);
                                          }
                                        } on HttpException catch (error) {
                                          print(
                                              "HttpException: ${error.message}");
                                        }
                                      }
                                      // AlertDialog 닫기
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 4),
                          child: Text(
                            "그만 보기",
                            style: TextStyle(
                                fontFamily: "Medium",
                                color: Colors.white,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: _bookOpacity, // Book()의 투명도 설정
                    duration: const Duration(seconds: 1), // 서서히 사라짐
                    child: (_bookOpacity > 0) ? Book(apiProvider) : Container(),
                  ),
                  AnimatedOpacity(
                    opacity: _pictureOpacity, // Picture()의 투명도 설정
                    duration: const Duration(seconds: 1), // 서서히 등장
                    child: (_pictureOpacity > 0) ? Picture(apiProvider) : Container(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 20,
              right: 0,
              child: Image.asset(
                "./assets/background/glasses.png",
                scale: 1,
              )),
        ],
      ),
    );
  }

  Widget Book(apiProvider) {
    return Stack(
      children: [
        Image.asset("./assets/background/book.png"),
        Padding(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.2,
              top: MediaQuery.of(context).size.height * 0.05),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.47,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Column(
                  key: animatedTextKey,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ensure that the `curPage` is within the valid range of `stories`
                    if (apiProvider.stories.isNotEmpty && curPage < apiProvider.stories.length)
                      AnimatedTextKit(
                        animatedTexts: [
                          TyperAnimatedText(
                            apiProvider.stories[curPage],
                            textStyle: const TextStyle(
                                fontFamily: "Writing", fontSize: 30),
                            speed: const Duration(milliseconds: 50),
                          ),
                        ],
                        repeatForever: false,
                        isRepeatingAnimation: false,
                        pause: const Duration(milliseconds: 100),
                        displayFullTextOnTap: true,
                        stopPauseOnTap: false,
                        onFinished: () {
                          setState(() {
                            textAnimation = false;
                          });
                        },
                      )
                    else
                    // Show a placeholder or a loading message when there is no story available
                      const Text(
                        '글 쓰는 중',
                        style: TextStyle(fontSize: 20, fontFamily: 'Writing'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_controller.currentIndex > 0)
          Positioned(
            left: 20,
            top: 230,
            child: GestureDetector(
              onTap: () {
                _controller.previousPage();
                setState(() {
                  textAnimation = true;
                  Future.delayed(const Duration(milliseconds: 1250), () {
                    _updateText(curPage - 1);
                  });
                });
              },
              child: const Icon(
                CupertinoIcons.arrowtriangle_left_fill,
                color: Colors.amber,
                size: 40,
              ),
            ),
          ),
        if (!flag && _controller.currentIndex < 3)
          Positioned(
            right: 10,
            top: 230,
            child: GestureDetector(
              onTap: () async {
                _controller.nextPage();
                setState(() {
                  textAnimation = true;
                  Future.delayed(const Duration(milliseconds: 1250), () {
                    _updateText(curPage + 1);
                  });
                });

                try {
                  final http.Response response = await http.post(
                      Uri.parse(
                          "http://ec2-3-38-111-246.ap-northeast-2.compute.amazonaws.com:8080/api/story/re"),
                      headers: <String, String>{
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode(
                          {'storyIndex': curPage + 1, 'id': apiProvider.id}));
                  if (response.statusCode != 200) {
                    print("Error response: ${response.body}");
                  } else {
                    final decodedBody = utf8.decode(response.bodyBytes);
                    print("success response: $decodedBody");

                    var jsonResponse = jsonDecode(decodedBody);

                    apiProvider.setStory(jsonResponse['story'] ?? "");
                    apiProvider.setFlag(jsonResponse['flag'] ?? false);
                    apiProvider.setId(jsonResponse['id'] ?? 0);
                  }
                } on HttpException catch (error) {
                  print("HttpException: ${error.message}");
                }
              },
              child: const Icon(
                CupertinoIcons.arrowtriangle_right_fill,
                color: Colors.amber,
                size: 40,
              ),
            ),
          ),
        SizedBox(
          height: 490,
          child: TurnPageView.builder(
            controller: _controller,
            itemCount: 4,
            itemBuilder: (context, index) {
              return Container();
            },
            overleafColorBuilder: (index) => const Color(0xffF2F3F5),
            animationTransitionPoint: 0.5,
          ),
        ),
      ],
    );
  }


  Widget Picture(apiProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Image.network(
                    apiProvider.image,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // 이미지가 로딩 완료되면 그대로 표시
                      } else {
                        // 로딩 중일 때 흰 배경에 "사진 로딩중" 텍스트 표시
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 350,
                            color: Colors.white, // 흰색 배경
                            child: const Center(
                              child: Text(
                                "사진 로딩중",
                                style: TextStyle(fontFamily: 'Writing', fontSize: 30),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                      // 이미지 로드 실패 시 기본 이미지를 보여줍니다.
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 350,
                          color: Colors.white, // 흰색 배경
                          child: const Center(
                            child: Text(
                              "사진 로딩중",
                              style: TextStyle(fontFamily: 'Writing', fontSize: 30),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Image.asset(
                  "./assets/background/frame.png", // 여기에 실제 이미지를 넣어주세요
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _downloadImage, // 다운로드 버튼 클릭 시
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                    child: Row(
                      children: [
                        Text(
                          "다운 받기 ",
                          style: TextStyle(fontFamily: "Light"),
                        ),
                        Icon(Icons.download_sharp),
                      ],
                    ),
                  )),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              "추천해 Dream~",
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 23,
                  color: Color(0xff212121)),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  list(context, "인생을 개쳑하는 인생그래프 만들기", "교육 프로그램",
                      "9월 6일 20:00 시작"),
                  const SizedBox(
                    height: 15,
                  ),
                  list(context, "카카오테크 부트캠프", "교육 프로그램", "9월 10일 20:00 시작"),
                  const SizedBox(
                    height: 15,
                  ),
                  list(context, "집가고싶다", "헤커톤 프로그램", "9월 30일 20:00 시작"),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

}

Widget list(context, String s1, String s2, String s3) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(8)),
    width: MediaQuery.of(context).size.width,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s1,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            s2,
            style: const TextStyle(
                color: Colors.blue, fontWeight: FontWeight.w500),
          ),
          Text(
            s3,
            style: const TextStyle(fontWeight: FontWeight.w500),
          )
        ],
      ),
    ),
  );
}
