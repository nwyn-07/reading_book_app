import 'package:flutter/material.dart';
import 'package:reading_book_app/core/MainShell.dart';
import 'package:reading_book_app/core/utils/Utils.dart';

void main() {
  runApp(
    MaterialApp(
      navigatorKey: Utils.navigatorKey,
      title: "Home",
      initialRoute: '/',
      routes: {
        '/': (context) => MainShell(),
        '/home': (context) => MainShell(),
        // '/studentInfo': (context) {
        //   var args = ModalRoute.of(context)!.settings.arguments as Map;
        //   return StudentDetailScreen(student: args["student"]);
        // },
      },
    ),
  );
}
