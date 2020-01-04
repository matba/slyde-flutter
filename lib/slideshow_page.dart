import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
    User.getUser().startSlideShow();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      return Scaffold(
        backgroundColor: Colors.black,
        body:
            (user.imgIdx == 0 && user.image1 == null)
                ? Center(
                    child: Text(
                      (user.images != null && user.images.length == 0) ? "No Image" : "Loading...",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ))
                : (user.imgIdx == 0 ? user.image1 : user.image2),

        );
    });
  }
}
