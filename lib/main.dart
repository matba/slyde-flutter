import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:fourame/classes/user.dart';
import 'package:fourame/landing_page.dart';
import 'package:fourame/mode_selection.dart';
import 'package:fourame/photo_manager.dart';
import 'package:fourame/slideshow_page.dart';
import 'login_screen.dart';
import 'signup_page.dart';

void main() => runApp(
    ChangeNotifierProvider(
      builder: (context) => User.createNewUserObject(context),
      child: FourameApp(),
    ));

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
        debugShowCheckedModeBanner: false,
        initialRoute: LandingPage.routeName,
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          LoginPage.routeName: (context) => LoginPage(),
          SignupPage.routeName: (context) => SignupPage(),
          ModeSelectionPage.routeName: (context) => ModeSelectionPage(),
          LandingPage.routeName: (context) => LandingPage(),
          PhotoManagerPage.routeName: (context) => PhotoManagerPage(),
          SlideShowPage.routeName: (context) => SlideShowPage()
        });
  }
}


