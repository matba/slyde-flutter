import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

import 'package:fourame/mode_selection.dart';
import 'package:fourame/signup_page.dart';
import 'constants.dart';
import 'classes/user.dart';

class LoginPage extends StatelessWidget {
  static const routeName = '/auth';

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
                image: AssetImage(StyleConstants.loginBackground),
                fit: BoxFit.cover,
                alignment: Alignment(-1, 0)),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              LoginWidget()
              ,
              Expanded(
                child: Container(),
              ),
            ],
          ),
        ));
  }
}

class LoginWidget extends StatefulWidget {
  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  static final double inputWidth = 280;
  static final double loginContainerSize = 400;

  final _formKey = GlobalKey<FormState>();

  int isEmailInvalid = 0;
  int isPasswordInvalid = 0;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool waitingForServer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String emailValidator(String email) {
    if (email.isEmpty) {
      setState(() {
        isEmailInvalid = 1;
      });
      return 'Email is required.';
    }
    if (!Constants.emailRegex.hasMatch(email)) {
      isEmailInvalid = 1;
      return 'Invalid email!';
    }

    setState(() {
      isEmailInvalid = 0;
    });
    return null;
  }

  String passwordValidator(String password) {
    if (password.length < 11) {
      setState(() {
        isPasswordInvalid = 1;
      });
      return 'Password should be atleast 11 characters';
    }
    setState(() {
      isPasswordInvalid = 0;
    });
    return null;
  }

  void _onLogin() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        waitingForServer = true;
      });
      Tuple2<String, String> result = await User.verifyLogin(
          emailController.text, passwordController.text);
      setState(() {
        waitingForServer = false;
      });

      if (result.item2 == null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("SessionToken", result.item1);
        Navigator.pushReplacementNamed(
            context, ModeSelectionPage.routeName);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Failed"),
              content: new Text(result.item2),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new FlatButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final InputDecoration inputDecoration = InputDecoration(
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        border: OutlineInputBorder(),
        labelStyle: Theme
            .of(context)
            .textTheme
            .display1);

    return Form(
        key: _formKey,
        child: Container(
          height: loginContainerSize + (
              isEmailInvalid +
              isPasswordInvalid) *
              22,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: 300,
              child: Column(
                children: <Widget>[
                  SvgPicture.asset(
                    StyleConstants.loginLogo,
                    width: 200,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            obscureText: false,
                            style: Theme
                                .of(context)
                                .textTheme
                                .display1,
                            decoration: inputDecoration.copyWith(
                                labelText: StringConstants.email),
                            validator: emailValidator,
                            controller: emailController,
                            enabled: !waitingForServer,
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            style: Theme
                                .of(context)
                                .textTheme
                                .display1,
                            obscureText: true,
                            decoration: inputDecoration.copyWith(
                                labelText: StringConstants.password),
                            validator: passwordValidator,
                            controller: passwordController,
                            enabled: !waitingForServer,
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: SizedBox(
                          width: inputWidth,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                            ),
                            textColor: Theme
                                .of(context)
                                .primaryColor,
                            color: Theme
                                .of(context)
                                .accentColor,
                            onPressed: (waitingForServer? null : _onLogin),
                            child: new Text(StringConstants.login),
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: SizedBox(
                          width: inputWidth,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                            ),
                            textColor: Theme
                                .of(context)
                                .accentColor,
                            color: Theme
                                .of(context)
                                .primaryColor,
                            onPressed: (waitingForServer? null : () =>
                            {
                              Navigator.pushNamed(
                                  context, SignupPage.routeName)
                            }),
                            child: new Text(StringConstants.register),
                          ))),
                ],
              )),
        )
    );
  }
}
