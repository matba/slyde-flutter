import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tuple/tuple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fourame/constants.dart';

class UserImage {
  String uuid;
  String name;
  String thumbnailAddress;
  int width;
  int height;
  String fileAddress;
  bool selected = false;

  UserImage(String uuid, String name, int width, int height) {
    this.uuid = uuid;
    this.name = name;
    this.width = width;
    this.height = height;
  }

  static Future<String> getThumbnailDirectory() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    String thumbnailDirectory =
        docDirectory.path + ServerConfiguration.thumbnailDirectory;
    bool exists = await Directory(thumbnailDirectory).exists();
    if (!exists) {
      try {
        await new Directory(thumbnailDirectory).create();
      } catch (e) {
        print(e);
      }
    }
    exists = await Directory(thumbnailDirectory).exists();

    if (!exists) {
      return null;
    } else {
      return thumbnailDirectory;
    }
  }

  Future<String> populateThumbnailAddress() async {
    String thumbnailDirectory = await getThumbnailDirectory();
    if (thumbnailDirectory == null) {
      print("Cannot create the thumbnails directory");
      return "Cannot create the thumbnails directory.";
    }

    final String filePath = thumbnailDirectory + "/" + uuid + ".jpg";

    if (FileSystemEntity.typeSync(filePath) == FileSystemEntityType.notFound) {
      print("File does not exist. Downloading it. File: " + filePath);
      http.Response response;
      try {
        String address = ServerConfiguration.protocol +
            ServerConfiguration.server +
            ServerConfiguration.imagesUrl +
            ServerConfiguration.paramIndicator +
            ServerConfiguration.thumbnailIndicator +
            ServerConfiguration.paramSeparator +
            ServerConfiguration.idIndicator +
            uuid;
        print("Making a request to " + address);
        response = await http.get(address,
            headers: NetworkUtil.getHeader(User.getUser().sessionToken));
      } catch (e) {
        print(e);
        print("Something went wrong while getting thumbnail from server.");
        return "Something went wrong while getting thumbnail from server.";
      }

      if (response.statusCode == 200) {
        File file = new File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
        this.thumbnailAddress = filePath;
        return null;
      } else {
        print("The call to get the image failed. error code :" +
            response.statusCode.toString() +
            response.body);
        return "The call to get the image failed.";
      }
    } else {
      this.thumbnailAddress = filePath;
      return null;
    }
  }

  Future<String> populateAddress() async {
    final docDirectory = await getApplicationDocumentsDirectory();
    String directory = docDirectory.path;

    final String filePath = directory + "/" + uuid + ".jpg";

    if (FileSystemEntity.typeSync(filePath) == FileSystemEntityType.notFound) {
      print("File does not exist. Downloading it. File: " + filePath);
      double screenLength =
          (User.getUser().screenWidth > User.getUser().screenHeight)
              ? User.getUser().screenWidth
              : User.getUser().screenHeight;
      http.Response response;
      try {
        response = await http.get(
            ServerConfiguration.protocol +
                ServerConfiguration.server +
                ServerConfiguration.imagesUrl +
                ServerConfiguration.paramIndicator +
                ServerConfiguration.idIndicator +
                uuid +
                ServerConfiguration.paramSeparator +
                ServerConfiguration.widthIndicator +
                screenLength.round().toString(),
            headers: NetworkUtil.getHeader(User.getUser().sessionToken));
      } catch (e) {
        print(e);
        print("Something went wrong while getting image from server.");
        return "Something went wrong while getting image from server.";
      }

      if (response.statusCode == 200) {
        try {
          (new File(filePath)).writeAsBytesSync(response.bodyBytes);
          this.fileAddress = filePath;
          print("Image was saved at " + filePath);
          return null;
        } catch (e) {
          print("Exception occurred while saving file." + e.toString());
          return "Cannot save file locally";
        }
      } else {
        print("The call to get the image failed. error code :" +
            response.statusCode.toString() +
            response.body);
        return "The call to get the image failed.";
      }
    } else {
      this.fileAddress = filePath;
      return null;
    }
  }
}

class NetworkUtil {
  static Map<String, String> getHeader(String sessionToken) {
    Map<String, String> headers = {};
    headers['cookie'] = "session_token=" + sessionToken + ";";
    return headers;
  }
}

class User extends ChangeNotifier {
  String sessionToken;
  String name;
  String email;
  bool isSessionTokenValid = false;
  bool isPopulated = false;
  Map<String, UserImage> images;
  bool imageRetrievalFailed = false;
  int lastSlideChangeTime;
  bool slideShowRunning = false;
  double screenWidth;
  double screenHeight;
  Image image1;
  Image image2;
  int imgIdx = 0;
  int updateCounter = 0;
  int cleanupCounter = 0;

  static User _singletonUser;

  static User getUser() {
    return _singletonUser;
  }

  User._() {
    populateUser();
  }

  static User createNewUserObject(BuildContext context) {
    User newUser = User._();
    _singletonUser = newUser;
    return _singletonUser;
  }

  void setScreenDimensions(double screenWidth, double screenHeight) {
    this.screenWidth = screenWidth;
    this.screenHeight = screenHeight;
  }

  Future<Null> populateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String tempToken = prefs.getString("SessionToken");
    if (tempToken == null) {
      isPopulated = true;
      notifyListeners();
      return;
    }
    sessionToken = tempToken;
    http.Response response;
    try {
      response = await http.get(
          ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.userUrl,
          headers: NetworkUtil.getHeader(sessionToken));
    } catch (e) {
      print(e);
      sessionToken = null;
      isPopulated = true;
      notifyListeners();
      return;
    }

    if (response.statusCode == 200) {
      isSessionTokenValid = true;
      isPopulated = true;
    } else {
      sessionToken = null;
      isPopulated = true;
    }
    notifyListeners();
  }

  void deleteImages() async {
    List<String> imageIdsToDelete = List();
    List<UserImage> imagesToDelete = List();
    for (UserImage img in images.values) {
      if (img.selected) {
        imageIdsToDelete.add(img.uuid);
        imagesToDelete.add(img);
      }
    }
    String json = jsonEncode({'images': imageIdsToDelete});
    dynamic response;
    final client = http.Client();

    try {
      http.Request request = http.Request(
          "DELETE",
          Uri.parse(ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.imagesUrl));
      request.headers['cookie'] = "session_token=" + sessionToken + ";";
      request.body = json;
      response = await client.send(request);
    } catch (e) {
      print(e);
      return;
    } finally {
      client.close();
    }

    if (response.statusCode == 200) {
      for (UserImage img in imagesToDelete) {
        images.remove(img.uuid);
      }
      print("Images successfully deleted");
      notifyListeners();
    } else {
      print("Error while deleting images." + response.statusCode.toString());
    }
  }

  void populateThumbnails() async {
    for (UserImage img in images.values) {
      await img.populateThumbnailAddress();
    }
    notifyListeners();
  }

  Future<Null> startSlideShow() async {
    if (slideShowRunning) {
      return;
    }
    slideShowRunning = true;

    new Timer(Duration(seconds: 1), () => this.handleSlideChange());
  }

  Image makeImage(String path) {
    return Image.file(new File(path),
        fit: BoxFit.scaleDown,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center);
  }

  void handleSlideChange() async {
    if (updateCounter == 0) {
      try {
        print("Initiating image update for user.");
        await populateImages(shouldNotify: false);
      } catch (e) {
        print("Exception while updating user images." + e.toString());
      }
      updateCounter = (updateCounter + 1) % Constants.imagesUpdateInterval;
    }

    List imagesList = List.from(images.values);
    if (imagesList.length != 0) {
      UserImage imageToShow =
      imagesList[new Random(lastSlideChangeTime).nextInt(
          imagesList.length)];
      String error = await imageToShow.populateAddress();
      if (error == null) {
        if (imgIdx == 1) {
          image1 = makeImage(imageToShow.fileAddress);
        } else {
          image2 = makeImage(imageToShow.fileAddress);
        }
        imgIdx = (imgIdx + 1) % 2;
        print("Switching to " + imageToShow.fileAddress);
        lastSlideChangeTime = DateTime
            .now()
            .millisecondsSinceEpoch;
        notifyListeners();
      } else {
        print(error);
      }
    } else {
      imgIdx = 0;
      image1 = null;
      image2 = null;
      notifyListeners();
    }

    if (cleanupCounter == 0) {
      try {
        print("Initiating cleanup for images.");
        await cleanUpImages();
      } catch (e) {
        print("Exception while updating user images." + e.toString());
      }
      cleanupCounter = (cleanupCounter + 1) % Constants.cleanupInterval;
    }

    new Timer(Duration(seconds: Constants.slideIntervalSec),
        () => this.handleSlideChange());
  }

  Future<Null> cleanUpImages() async {
    final Directory docDirectory = await getApplicationDocumentsDirectory();
    cleanUpDirectory(docDirectory);

    // now delete the thumbnail
    String thumbnailDirectory = await UserImage.getThumbnailDirectory();
    if (thumbnailDirectory != null) {
      Directory directory = new Directory(thumbnailDirectory);
      cleanUpDirectory(directory);
    } else {
      print("Cannot create the thumbnails directory");
    }
  }

  void cleanUpDirectory(Directory directory) {
    List<FileSystemEntity> files = directory.listSync(followLinks: false);
    for (FileSystemEntity file in files) {
      String fileName = file.path.split("/").last;
      if (fileName.endsWith(".jpg")) {
        String imageId = fileName.substring(0, fileName.length - 4);
        if (!images.containsKey(imageId)) {
          print("Cleaning up file: " + file.path);
          try {
            file.deleteSync();
          } catch (e) {
            print("Deleting file failed. File path: " + file.path);
          }
        }
      }
    }
  }

  Future<Null> signout() async {
    try {
      await http.get(
          ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.signoutUrl,
          headers: NetworkUtil.getHeader(sessionToken));
    } catch (e) {
      print(e);
    }
  }

  Future<Null> populateImages({bool shouldNotify = true}) async {
    if (images == null) {
      images = new Map<String, UserImage>();
    }
    dynamic decoded;
    try {
      print("Making a backend call!" +
          ServerConfiguration.protocol +
          ServerConfiguration.server +
          ServerConfiguration.imagesUrl);
      http.Response response = await http.get(
          ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.imagesUrl,
          headers: NetworkUtil.getHeader(sessionToken));
      if (response.statusCode == 200) {
        decoded = jsonDecode(response.body);
      } else {
        print("Image backend failed with error! Status code: " +
            response.statusCode.toString() +
            response.body);
      }
    } catch (e) {
      print(e);
      print("Errror calling the image backend!" + e.toString());
    }

    if (decoded != null) {
      Set deletedImages = Set.from(images.keys);
      for (Map im in (decoded['images'] as List)) {
        if (!images.containsKey(im['id'])) {
          print("New images was added. Name: " + im['name']);
          final curImage =
              UserImage(im['id'], im['name'], im['width'], im['height']);
          images[im['id']] = curImage;
        } else {
          deletedImages.remove(im['id']);
        }
      }
      for (String imId in deletedImages) {
        print("Image was deleted. Name: " + images[imId].name);
        images.remove(imId);
      }
    } else {
      if (images == null) {
        imageRetrievalFailed = true;
      }
    }
    if (shouldNotify) {
      notifyListeners();
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = image.path.split("/").last;
    dynamic response;
    dynamic decoded;
    try {
      var stream =
          new http.ByteStream(DelegatingStream.typed(image.openRead()));
      var length = await image.length();
      var uri = Uri.parse(ServerConfiguration.protocol +
          ServerConfiguration.server +
          ServerConfiguration.imagesUrl);
      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('image', stream, length,
          filename: basename(image.path));
      //contentType: new MediaType('image', 'png'));
      request.headers['cookie'] = "session_token=" + sessionToken + ";";
      request.fields['name'] = fileName;
      request.files.add(multipartFile);
      response = await request.send();
      String respStr = await response.stream.bytesToString();
      decoded = jsonDecode(respStr);
    } catch (e) {
      print("Exception occurred while uploading image. Exception:" +
          e.toString());
      return "Cannot upload image at this time.";
    }

    if (response.statusCode == 200) {
      print("upload image was successful.");
      UserImage newImage = UserImage(
          decoded['id'], decoded['name'], decoded['width'], decoded['height']);
      images[decoded['id']] = newImage;
      notifyListeners();
      newImage.populateThumbnailAddress().then((err) => notifyListeners());
      return null;
    } else {
      print("The call to upload the image failed. error code :" +
          response.statusCode.toString() +
          decoded['description']);
      return "Image cannot be uploaded for following reason: " +
          decoded['description'];
    }
  }

  static Future<Tuple2<bool, String>> createUser(
      String name, String email, String password) async {
    String json =
        jsonEncode({'name': name, 'email': email, 'password': password});

    dynamic response;
    try {
      response = await http.post(
          ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.signupUrl,
          body: json);
    } catch (e) {
      print(e);
      return Tuple2(false, 'unable to create a user at this time.');
    }

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded != null &&
          decoded['alreadyRequested'] != null &&
          decoded['alreadyRequested'] == true) {
        return Tuple2(true, null);
      } else {
        return Tuple2(false, null);
      }
    } else {
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print(e);
        return Tuple2(false, 'unable to create a user at this time.');
      }
      if (decoded != null && decoded['description'] != null) {
        return Tuple2(false, decoded['description']);
      } else {
        return Tuple2(false, 'unable to create a user at this time.');
      }
    }
  }

  static Future<String> verifyEmail(
      String email, String verificationCode) async {
    String json = jsonEncode({'email': email, 'code': verificationCode});

    dynamic response;
    try {
      response = await http.post(
          ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.verifyUrl,
          body: json);
    } catch (e) {
      print(e);
      return 'unable to verify a user at this time.';
    }

    if (response.statusCode == 200) {
      return null;
    } else {
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print(e);
        return 'unable to verify a user at this time.';
      }
      if (decoded != null && decoded['description'] != null) {
        return decoded['description'];
      } else {
        return 'unable to verify a user at this time.';
      }
    }
  }

  static Future<Tuple2<String, String>> verifyLogin(
      String email, String password) async {
    String json = jsonEncode({'email': email, 'password': password});

    dynamic response;
    try {
      response = await http.post(
          ServerConfiguration.protocol +
              ServerConfiguration.server +
              ServerConfiguration.loginUrl,
          body: json);
    } catch (e) {
      print(e);
      return Tuple2(null, 'unable to login at this time.');
    }

    if (response.statusCode == 200) {
      String rawCookie = response.headers['set-cookie'];
      if (rawCookie != null && Constants.sessionToken.hasMatch(rawCookie)) {
        String cookie = Constants.sessionToken.firstMatch(rawCookie).group(1);
        return Tuple2(cookie, null);
      } else {
        return Tuple2(null, 'unable to login at this time.');
      }
    } else {
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print(e);
        return Tuple2(null, 'unable to login at this time.');
      }
      if (decoded != null && decoded['description'] != null) {
        return Tuple2(null, decoded['description']);
      } else {
        return Tuple2(null, 'unable to login at this time.');
      }
    }
  }
}
