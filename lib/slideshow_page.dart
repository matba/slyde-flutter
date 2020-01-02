import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:provider/provider.dart';

import 'classes/user.dart';

class SlideShowPage extends StatelessWidget {
  static const routeName = '/slide';

  @override
  Widget build(BuildContext context) {
    return PhotoSlideShowWidget();
  }
}

class PhotoSlideShowWidget extends StatefulWidget {
  @override
  _PhotoSlideShowState createState() => _PhotoSlideShowState();
}

class _PhotoSlideShowState extends State<PhotoSlideShowWidget> {
  @override
  void initState() {
    super.initState();
    User.getUser().populateImages().then((x) => User.getUser().startSlideShow());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
        return Material(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: user.slideShowImageAddress == null ? AssetImage(StyleConstants.loginBackground) : FileImage(new File(user.slideShowImageAddress)),
                    fit: BoxFit.cover,
                    alignment: Alignment(-1, 0)),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ));
      }
    );
  }
}
