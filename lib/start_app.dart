import 'package:flutter/material.dart';
import 'package:moapp_project/login_page.dart';
import 'package:moapp_project/record_my_day.dart';
import 'package:moapp_project/register_page.dart';
import 'package:moapp_project/select_music.dart';

class StartApp extends StatelessWidget {
  const StartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RecordMyday',
      initialRoute: '/login',
      routes: {
        '/record_my_day': (BuildContext context) => const RecordMyDay(),
        '/select_music': (BuildContext context) => const SelectMusic(),
        '/login': (BuildContext context) => const LoginPage(),
        '/register': (BuildContext context) => const RegisterPage(),
      },
    );
  }
}
