import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/postit_provider.dart';

class PostItTextField extends StatefulWidget {
  final int index;
  static final List<String> question = ["당신이 꾼 꿈은 무엇인가요?", "어떤 사람이 되고 싶었나요?"];
  static final List<String> hintText = ["예시) 선생님, 의사", "예시) 나는 아이들에게 어머니같은\n 선생님이 되고 싶었어"];

  const PostItTextField({
    super.key,
    required this.index,
  });

  @override
  _PostItTextFieldState createState() => _PostItTextFieldState();
}

class _PostItTextFieldState extends State<PostItTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final postitProvider = Provider.of<PostitProvider>(context, listen: false);
    _controller = TextEditingController(text: postitProvider.getText(widget.index));

    // Update the provider when the text changes
    _controller.addListener(() {

        postitProvider.updateText(widget.index, _controller.text);

    });
  }

  @override
  void didUpdateWidget(covariant PostItTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) { // 위젯이 mounted 상태일 때만 실행
        final postitProvider = Provider.of<PostitProvider>(context, listen: false);
        _controller.text = postitProvider.getText(widget.index);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Image.asset(
              "./assets/background/postit.png",
              scale: 1,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 80),
              child: Column(
                children: [
                  Text(PostItTextField.question[widget.index], style: TextStyle(fontSize: 20, fontFamily: "Bold"),),
                  const SizedBox(height: 20,),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: TextField(
                      expands: true,
                      maxLines: null,
                      controller: _controller,
                      textAlignVertical: TextAlignVertical.top,
                      cursorColor: Colors.black,
                      style: const TextStyle(fontFamily: "Writing", fontSize: 30),
                      decoration: InputDecoration(
                        hintText: PostItTextField.hintText[widget.index],
                        hintStyle: const TextStyle(color: Color(0xff919191)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
