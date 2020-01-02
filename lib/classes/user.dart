import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

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
  String fileAddress;
  bool selected = false;

  UserImage(String uuid, String name) {
    this.uuid = uuid;
    this.name = name;
  }

  Future<String> populateAddress(bool isThumbnail) async {
    final docDirectory = await getApplicationDocumentsDirectory();
    String directory = docDirectory.path;
    if (isThumbnail) {
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
        print("Cannot create the thumbnails directory");
        return "Cannot create the thumbnails directory.";
      }
      directory = thumbnailDirectory;
    }

    final String filePath = directory + "/" + uuid + ".jpg";

    if (FileSystemEntity.typeSync(filePath) == FileSystemEntityType.notFound) {
      print("File does not exist. Downloading it. File: " + filePath);
      http.Response response;
      try {
        response = await http.get(
            ServerConfiguration.protocol +
                ServerConfiguration.server +
                ServerConfiguration.imagesUrl +
                ServerConfiguration.paramIndicator +
                (isThumbnail
                    ? ServerConfiguration.thumbnailIndicator +
                        ServerConfiguration.paramSeparator
                    : "") +
                ServerConfiguration.idIndicator +
                uuid,
            headers: NetworkUtil.getHeader(User.getUser().sessionToken));
      } catch (e) {
        print(e);
        print("Something went wrong while getting thumbnail from server.");
        return "Something went wrong while getting thumbnail from server.";
      }

      if (response.statusCode == 200) {
        File file = new File(filePath);
        file.writeAsBytesSync(response.bodyBytes);
        if (isThumbnail) {
          this.thumbnailAddress = filePath;
        } else {
          this.fileAddress = filePath;
        }
        return null;
      } else {
        print("The call to get the image failed. error code :" +
            response.statusCode.toString() +
            response.body);
        return "The call to get the image failed.";
      }
    } else {
      if (isThumbnail) {
        this.thumbnailAddress = filePath;
      } else {
        this.fileAddress = filePath;
      }
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
  List<UserImage> images;
  bool imageRetrievalFailed = false;
  String slideShowImageAddress;
  int lastSlideChangeTime;
  bool slideShowRunning = false;
  static User _singletonUser;

  static User getUser() {
    if (_singletonUser == null) {
      _singletonUser = User._();
    }
    return _singletonUser;
  }

  User._() {
    populateUser();
  }

  void populateUser() async {
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
    for (UserImage img in images) {
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
        images.remove(img);
      }
      print("Images successfully deleted");
      notifyListeners();
    } else {
      print("Error while deleting images." + response.statusCode.toString());
    }
  }

  void populateThumbnails() async {
    for (UserImage img in images) {
      await img.populateAddress(true);
    }
    notifyListeners();
  }

  Future<Null> startSlideShow() async {
    if (slideShowRunning) {
      return;
    }
    slideShowRunning = true;
    for (UserImage img in images) {
      await img.populateAddress(false);
      if (slideShowImageAddress == null ||
          DateTime.now().millisecondsSinceEpoch - lastSlideChangeTime > 60000) {
        slideShowImageAddress = img.fileAddress;
        print("Switching to " + slideShowImageAddress);
        lastSlideChangeTime = DateTime.now().millisecondsSinceEpoch;
        notifyListeners();
      }
    }

    new Timer(Duration(seconds: 20), () => this.handleSlideChange());
  }

  void handleSlideChange() {
    slideShowImageAddress =
        images[new Random(lastSlideChangeTime).nextInt(images.length - 1)].fileAddress;
    print("Switching to " + slideShowImageAddress);
    lastSlideChangeTime = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    new Timer(Duration(seconds: 20), () => this.handleSlideChange());
  }

  Future<Null> populateImages() async {
    if (images == null) {
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
        images = new List();
        for (Map im in (decoded['images'] as List)) {
          final curImage = UserImage(im['id'], im['name']);
          images.add(curImage);
        }
      } else {
        images = [];
        imageRetrievalFailed = true;
      }
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
      UserImage newImage = UserImage(decoded['id'], decoded['name']);
      images.add(newImage);
      notifyListeners();
      newImage.populateAddress(true).then((err) => notifyListeners());
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
        return decoded['description'];
      } else {
        return Tuple2(null, 'unable to login at this time.');
      }
    }
  }
}
