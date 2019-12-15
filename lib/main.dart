import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        ),
        initialRoute: '/',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => LoginPage(),
        });
  }
}

class LoginPage extends StatelessWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/memory-login.jpg'),
            fit: BoxFit.cover,
            alignment: Alignment(-1, 0)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Container(
            height: 410,
            decoration: BoxDecoration(
              color: Colors.black26,
            ),
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                width: 300,
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/logo-login.svg',
                      width: 200,
                    ),
                    Container(
                      height: 15,
                    ),
                SizedBox(
                  width: 250,
                  child:TextField(
                      obscureText: false,
                      style: new TextStyle(
                          fontSize: 12.0,
                          height: 1.0,
                          color: Colors.black
                      ),
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                            // width: 0.0 produces a thin "hairline" border
                            borderSide: const BorderSide(
                                color: Colors.white, width: 1.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        border: OutlineInputBorder(),
                        labelStyle: TextStyle(
                          color: Colors.white,
                        ),
                        labelText: 'Email',
                      ),
                    )),
                    Container(
                      height: 5,
                    ),
                    SizedBox(

                        width: 250,
                        child: TextField(
                          style: new TextStyle(
                              fontSize: 12.0,
                              height: 1.0,
                              color: Colors.black
                          ),
                          obscureText: true,
                          decoration: InputDecoration(
                            enabledBorder: const OutlineInputBorder(
                                // width: 0.0 produces a thin "hairline" border
                                borderSide: const BorderSide(
                                    color: Colors.white, width: 1.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0))),
                            border: OutlineInputBorder(),
                            labelStyle: TextStyle(
                              color: Colors.white,
                            ),
                            labelText: 'Password',
                          ),
                        )),
                    SizedBox(
                        width: 250,
                        child: RaisedButton(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                          textColor: Colors.white,
                          color: Colors.pink,
                          onPressed: () => {},
                          child: new Text("Login"),
                        )),
                    SizedBox(
                        width: 250,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                          ),
                          textColor: Colors.pink,
                          color: Colors.white,
                          onPressed: () => {},
                          child: new Text("Create an account"),
                        )),
                  ],
                )),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    ));
  }
}
