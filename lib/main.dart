import 'package:flutter/material.dart';
import 'package:hackathon/controller/postit_provider.dart';
import 'package:hackathon/view/home_page.dart';
import 'package:provider/provider.dart';

import 'controller/fade_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FadeProvider()),
        ChangeNotifierProvider(create: (_) => PostitProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DREAM',
      theme: ThemeData(
        primaryColor: const Color(0xffFCF9D3),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}