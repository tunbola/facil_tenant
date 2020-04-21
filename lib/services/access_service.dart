import "package:facil_tenant/services/storage_service.dart";
import "dart:convert" as conv;
import 'package:intl/intl.dart';

class AccessService {
  static final String _key = "FacilAccessKey";
  static String _userAccessCache = "";
  static List<String> _supportedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  static List<String> _imageExtensions = ['jpg', 'png', 'jpeg'];
  
  /// setAccess method takes information sent from the server
  /// and calls a method from LocalStorage class to save information
  /// in storage
  static Future<bool> setAccess(String userDetails) async {
    dynamic localStorage =
        await LocalStorage.setItem(AccessService._key, userDetails);
    if (localStorage == false) {
      return localStorage;
    }
    return true;
  }

  static List<String> get supportedExtensions {
    return _supportedExtensions;
  }

  static List<String> get supportedImagesExtensions {
    return _imageExtensions;
  }

  static String getfileExtension(String fileName) {
    List splitName = fileName.split(".");
    String fileExt = splitName[splitName.length - 1];
    return fileExt;
  }

  static String getfileName(String filePath) {
    List<String> fileInfo = filePath.split('/');
    return fileInfo[fileInfo.length - 1];
  }

  /// saveLogin saves users' login information on the device
  static Future<bool> saveLogin(String loginDetails) async {
    dynamic localStorage =
        await LocalStorage.setItem("facil_login", loginDetails);
    if (localStorage == false) {
      return localStorage;
    }
    return true;
  }

  /// saveLogin saves users' login information on the device
  static Future<Map<String, dynamic>> getLoginInfo() async {
    dynamic response = await LocalStorage.getItem("facil_login");
    if (response == false) {
      return null;
    }
    Map<String, dynamic> userlogin = conv.json.decode(response);
    return userlogin;
  }


  /// deletes saved user key and redirects user to login page
  static void logOut() async {
    await LocalStorage.removeItem(AccessService._key);
    AccessService.clearCache();
    return;
  }

  /// fetches user access details from the file system
  /// if it doesn't exist in the _userAccessCache static
  /// property
  static Future<String> _fsContent() async {
    if (AccessService._userAccessCache.length > 1) {
      return AccessService._userAccessCache;
    }
    try {
      dynamic response = await LocalStorage.getItem(AccessService._key);
      if (response != false) {
        AccessService._userAccessCache = response.toString();
        return response.toString();
      }
    } catch (e) {}
    AccessService.logOut();
    return null;
  }

  static void clearCache() {
    _userAccessCache = "";
  }

  /// gets user id from the storage
  static Future<String> getUserId() async {
    String fscontent = await AccessService._fsContent();
    String userid = conv.json.decode(fscontent)["user_id"].toString();
    return userid;
  }

  /// gets accessToken from storage
  static Future<String> accessToken() async {
    String fscontent = await AccessService._fsContent();
    String access = conv.json.decode(fscontent)["token"];
    return access;
  }

  /// gets user's role from storage
  static Future<String> userRole() async {
    String fscontent = await AccessService._fsContent();
    String response = (conv.json.decode(fscontent)["role"]["id"]).toString();
    return response;
  }

  /// gets username from storage
  static Future<String> getUserName() async {
    String fscontent = await AccessService._fsContent();
    dynamic name = conv.json.decode(fscontent)["othernames"];
    String response = name == null ? "No name yet" : name;
    return response;
  }

  static Future<Map<String, dynamic>> getProperty() async {
    String fscontent = await AccessService._fsContent();
    Map<String, dynamic> property = conv.json.decode(fscontent)["property"];
    return property;
  }

  static bool isPhoneNumber(String phoneNumber) {
    bool pnValid = RegExp(r"^[0-9]{11}$").hasMatch(phoneNumber);
    return pnValid;
  }

  static bool isValidCode(String smsCode) {
    bool isValid = RegExp(r"^[0-9]{6}$").hasMatch(smsCode);
    return isValid;
  }

  static bool isValidEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  static Future<Map<String, String>> requestHeader() async {
    String access = await AccessService.accessToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Authorization": "Bearer $access"
    };
  }

  static String getLastContent(String content) {
    List<String> listOfStrings = content.split("|");
    return listOfStrings[listOfStrings.length - 1];
  }

  static String getLastTime(String sentTimeGroup) {
    String dateTime = AccessService.getLastContent(sentTimeGroup);
    return DateFormat.yMMMd().format(DateTime.parse(dateTime));
  }

  static Future<int> numberOfZeros(String msgStateGroup) async {
    List listOfMsgState = msgStateGroup.split("|");
    int numberOfUnread = 0;
    String userId = await getUserId();
    for (var i = 0; i < listOfMsgState.length; i++) {
      List splitEachState = listOfMsgState[i].split(',');
      if (splitEachState[0].toString() == userId) {
        if (splitEachState[1] == "0") {
          numberOfUnread += 1;
        }
      }
    }
    return numberOfUnread;
  }
}