import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'classes/user.dart';

class PhotoManagerPage extends StatelessWidget {
  static const routeName = '/manager';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Manage Photos'),
          actions: <Widget>[
            // Add 3 lines from here...
            IconButton(
                icon: Icon(Icons.add_a_photo),
                onPressed: () => uploadImage(context)),
            IconButton(icon: Icon(Icons.delete), onPressed: deleteImagePressed),
          ],
        ),
        body: PhotosGridviewWidget());
  }

  void uploadImage(BuildContext context) async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      String error = await User.getUser().uploadImage(file);
      if (error != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Error."),
              content: new Text(error),
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

  void deleteImagePressed() async {
    print("Deleting images");
    User.getUser().deleteImages();
  }
}

class PhotosGridviewWidget extends StatefulWidget {
  @override
  _PhotosGridviewState createState() => _PhotosGridviewState();
}

class _PhotosGridviewState extends State<PhotosGridviewWidget> {
  @override
  void initState() {
    super.initState();
    User.getUser().populateImages().then((x) => User.getUser().populateThumbnails());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, child) {
      if (user.images != null) {
        if (user.imageRetrievalFailed) {
          return Center(
            child: Text("Error retrieving images."),
          );
        }
        return GridView.count(
          primary: false,
          padding: const EdgeInsets.all(20),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 4,
          children: generateImageList(user.images),
        );
      } else {
        return Center(
          child: Text("Loading..."),
        );
      }
    });
  }

  List<Widget> generateImageList(Map<String, UserImage> images) {
    List<UserImage> imageList = List.from(images.values);
    List<Widget> result = new List(images.length);
    for (var i = 0; i < imageList.length; i++) {
      result[i] = createImageContainer(imageList[i]);
    }
    return result;
  }

  Widget createImageContainer(UserImage img) {
    return GestureDetector(
        // When the child is tapped, show a snackbar.
        onTap: () {
          setState(() {
            img.selected = !img.selected;
          });
        },
        // The custom button
        child: Stack(alignment: const Alignment(-0.9, 0.9), children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: (img.thumbnailAddress == null)
                      ? AssetImage('assets/image-placeholder.png')
                      : FileImage(new File(img.thumbnailAddress)),
                  fit: BoxFit.cover,
                  alignment: Alignment(-1, 0)),
            ),
            padding: const EdgeInsets.all(8),
            child: Container(),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black45,
            ),
            child: Icon(
              img.selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: Colors.white,
            ),
          )
        ]));
  }
}
