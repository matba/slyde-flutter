import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatelessWidget {
  static const routName = '/auth';
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  Widget build(BuildContext context) {
    final InputDecoration inputDecoration = InputDecoration(
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
            borderSide: const BorderSide(
                color: Colors.white, width: 1.0),
            borderRadius:
            BorderRadius.all(Radius.circular(20.0))),
        border: OutlineInputBorder(),
        labelStyle: Theme.of(context).textTheme.display1
    );
    return Material(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/memory-login.png'),
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
                  color: Theme.of(context).backgroundColor,
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
                              style: Theme.of(context).textTheme.display1,
                              decoration: inputDecoration.copyWith(labelText: 'Email'),
                            )),
                        Container(
                          height: 5,
                        ),
                        SizedBox(
                            width: 250,
                            child: TextField(
                              style: Theme.of(context).textTheme.display1,
                              obscureText: true,
                              decoration: inputDecoration.copyWith(labelText: 'Password'),
                            )),
                        SizedBox(
                            width: 250,
                            child: RaisedButton(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                              ),
                              textColor: Theme.of(context).primaryColor,
                              color: Theme.of(context).accentColor,
                              onPressed: () => {},
                              child: new Text("Login"),
                            )),
                        SizedBox(
                            width: 250,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                              ),
                              textColor: Theme.of(context).accentColor,
                              color: Theme.of(context).primaryColor,
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