import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:fourame/mode_selection.dart';
import 'package:fourame/login_screen.dart';
import 'constants.dart';
import 'classes/user.dart';

class LandingPage extends StatelessWidget {
  static const routeName = '/landing';

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(
      builder: (context, user, child) {
        if (user.screenWidth == null) {
          user.setScreenDimensions(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height);
        }
        if (user.isPopulated) {
          if (user.isSessionTokenValid) {
            return ModeSelectionPage();
          } else {
            return LoginPage();
          }
        }

        return Material(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.black
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  SvgPicture.asset(
                    StyleConstants.loginLogo,
                    width: 200,
                  )
                  ,
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ));
      },
    );
  }


}