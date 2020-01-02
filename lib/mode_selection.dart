import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:fourame/photo_manager.dart';
import 'package:fourame/slideshow_page.dart';
import 'constants.dart';

class ModeSelectionPage extends StatelessWidget {
  static const routeName = '/mode';

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
          ModeSelectionWidget(),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    ));
  }
}

class ModeSelectionWidget extends StatefulWidget {
  @override
  _ModeSelectionState createState() => _ModeSelectionState();
}

class _ModeSelectionState extends State<ModeSelectionWidget> {
  static final double inputWidth = 280;
  static final double modeSelectionContainerSize = 130;

  bool waitingForServer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height:modeSelectionContainerSize,
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
                  padding: EdgeInsets.symmetric(vertical: 0),
                  child: SizedBox(
                      width: inputWidth,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(18.0),
                        ),
                        textColor: Theme.of(context).accentColor,
                        color: Theme.of(context).primaryColor,
                        onPressed: (waitingForServer
                            ? null
                            : () => {
                          Navigator.pushNamed(
                              context, PhotoManagerPage.routeName)
                        }),
                        child: new Text(StringConstants.photoManagement),
                      ))),
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
                        onPressed: (waitingForServer
                            ? null
                            : () => {
                          Navigator.pushNamed(
                              context, SlideShowPage.routeName)
                        }),
                        child: new Text(StringConstants.digitalPhotoFrame),
                      ))),
            ],
          )),
    );
  }
}
