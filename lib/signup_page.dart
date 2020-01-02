import 'package:flutter/material.dart';
import 'package:fourame/login_screen.dart';
import 'package:tuple/tuple.dart';
import 'constants.dart';
import 'classes/user.dart';

class SignupPage extends StatelessWidget {
  static const routeName = '/signup';

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
          SignupWidget(),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    ));
  }
}

class SignupWidget extends StatefulWidget {
  @override
  _SignupWidgetState createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  static final double inputWidth = 280;
  static final double expandedHeight = 410;
  static final double collapsedHeight = 350;
  static final RegExp nameRegex =
      RegExp(r"^([a-z]|[0-9]|-)+$", caseSensitive: false);

  int isNameInvalid = 0;
  int isEmailInvalid = 0;
  int isPasswordInvalid = 0;
  int isConfirmPasswordInvalid = 0;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final confirmationCodeController = TextEditingController();
  bool showConfirmation = false;
  bool waitingForServer = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  String nameValidator(String name) {
    if (!nameRegex.hasMatch(name)) {
      setState(() {
        isNameInvalid = 1;
      });
      return 'the name can only have a-z,1-9 and dash (-)';
    }
    setState(() {
      isNameInvalid = 0;
    });
    return null;
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

  String confirmPasswordValidator(String confirmPassword) {
    if (confirmPassword != passwordController.text) {
      setState(() {
        isConfirmPasswordInvalid = 1;
      });
      return "Password and confirmation do not match";
    }
    setState(() {
      isConfirmPasswordInvalid = 0;
    });
    return null;
  }

  void _onRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        waitingForServer = true;
      });
      Tuple2<bool, String> result = await User.createUser(
          nameController.text, emailController.text, passwordController.text);
      setState(() {
        waitingForServer = false;
      });
      if (result.item2 == null) {
        if (result.item1) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AlertDialog(
                title: new Text("Already requested."),
                content: new Text("The user already registered and waiting for email verification. If you have the verification code please provide it."),
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
        setState(() {
          showConfirmation = true;
        });
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

  void _onVerify() async {
    setState(() {
      waitingForServer = true;
    });
    String result = await User.verifyEmail(emailController.text, confirmationCodeController.text);
    setState(() {
      waitingForServer = false;
    });

    if (result == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Success"),
            content: new Text("The account successfully registered. Please use the login form to log in."),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new FlatButton(
                child: new Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(
                      context, LoginPage.routeName);
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
            title: new Text("Failed"),
            content: new Text(result),
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

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    confirmationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final InputDecoration inputDecoration = InputDecoration(
        enabledBorder: const OutlineInputBorder(
            // width: 0.0 produces a thin "hairline" border
            borderSide: const BorderSide(color: Colors.white, width: 1.0),
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        border: OutlineInputBorder(),
        labelStyle: Theme.of(context).textTheme.display1);

    return Form(
        key: _formKey,
        child: Container(
          height: showConfirmation
              ? expandedHeight
              : (collapsedHeight +
                  ((isNameInvalid +
                          isEmailInvalid +
                          isPasswordInvalid +
                          isConfirmPasswordInvalid) *
                      22)),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              width: 300,
              child: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            obscureText: false,
                            enabled: !showConfirmation && !waitingForServer,
                            style: Theme.of(context).textTheme.display1,
                            decoration: inputDecoration.copyWith(
                                labelText: StringConstants.yourName),
                            validator: nameValidator,
                            controller: nameController,
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            obscureText: false,
                            enabled: !showConfirmation && !waitingForServer,
                            style: Theme.of(context).textTheme.display1,
                            decoration: inputDecoration.copyWith(
                                labelText: StringConstants.email),
                            validator: emailValidator,
                            controller: emailController,
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            style: Theme.of(context).textTheme.display1,
                            obscureText: true,
                            enabled: !showConfirmation && !waitingForServer,
                            decoration: inputDecoration.copyWith(
                                labelText: StringConstants.password),
                            validator: passwordValidator,
                            controller: passwordController,
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      child: SizedBox(
                          width: inputWidth,
                          child: TextFormField(
                            style: Theme.of(context).textTheme.display1,
                            obscureText: true,
                            enabled: !showConfirmation && !waitingForServer,
                            decoration: inputDecoration.copyWith(
                                labelText: StringConstants.confirmPassword),
                            validator: confirmPasswordValidator,
                            controller: confirmPasswordController,
                          ))),
                  Visibility(
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 3),
                          child: SizedBox(
                              width: inputWidth,
                              child: TextFormField(
                                style: Theme.of(context).textTheme.display1,
                                obscureText: false,
                                decoration: inputDecoration.copyWith(
                                    labelText:
                                        StringConstants.confirmationCode),
                                enabled: true,
                                controller: confirmationCodeController,
                              ))),
                      visible: showConfirmation),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: SizedBox(
                          width: inputWidth,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                            ),
                            textColor: Theme.of(context).primaryColor,
                            color: Theme.of(context).accentColor,
                            onPressed: waitingForServer ? null : (showConfirmation ? _onVerify : _onRegister),
                            child: new Text(showConfirmation ? StringConstants.verify : StringConstants.register),
                          ))),
                  Container(
                      padding: EdgeInsets.symmetric(vertical: 0),
                      child: SizedBox(
                          width: inputWidth,
                          child: RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(18.0),
                            ),
                            textColor: Theme.of(context).accentColor,
                            color: Theme.of(context).primaryColor,
                            onPressed: () => {
                              Navigator.pushReplacementNamed(
                                  context, LoginPage.routeName)
                            },
                            child: new Text(StringConstants.backToLogin),
                          ))),
                ],
              )),
        ));
  }
}
