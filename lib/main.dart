import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_page.dart';

void main() => runApp(FourameApp());

class FourameApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '4ame',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.pink,
          primaryColor: Colors.white,
          accentColor: Colors.pink,
          hintColor: Colors.white,
          backgroundColor: Colors.black26,
          textTheme: TextTheme(
            display1: TextStyle(
                fontSize: 12.0,
                height: 1.0,
                color: Colors.white
            )
          )
        ),
        initialRoute: LoginPage.routName,
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          LoginPage.routName: (context) => LoginPage(),
          SignupPage.routName: (context) => SignupPage(),
        });
  }
}


