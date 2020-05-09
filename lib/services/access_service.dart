import "package:facil_tenant/services/storage_service.dart";
import "dart:convert" as conv;
import 'package:intl/intl.dart';

class AccessService {

  static final String _key = "FacilAccessKey";
  static List<String> _supportedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
  static List<String> _imageExtensions = ['jpg', 'png', 'jpeg'];

  /// setAccess method takes information sent from the server
  /// and calls a method from LocalStorage class to save information
  /// in storage
  static Future<dynamic> setAccess(String userDetails) async {
    dynamic localStorage =
        await LocalStorage.setItem(AccessService._key, userDetails);
    if (localStorage == false) {
      return localStorage;
    }
    return true;
  }

  static Future<bool> saveLastVisitedRoute(String routeName) async {
    dynamic localStorage = await LocalStorage.setItem("lastRoute", routeName);
    if (localStorage == false) return localStorage;
    return true;
  }

  static Future<String> getLastVisitedRoute() async {
    dynamic content = await LocalStorage.getItem("lastRoute");
    if (content == false) return null;
    return content;
  }

  static Future<bool> deleteLastRouteRoute() async {
    bool state = await LocalStorage.removeItem("lastRoute");
    return state;
  }

  static List<String> get supportedExtensions => _supportedExtensions;

  static List<String> get supportedImagesExtensions => _imageExtensions;

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
        await LocalStorage.setItem("facilLogin", loginDetails);
    if (localStorage == false) return localStorage;
    return true;
  }

  /// saveLogin saves users' login information on the device
  static Future<Map<String, dynamic>> getLoginInfo() async {
    dynamic response = await LocalStorage.getItem("facilLogin");
    if (response == false) return null;
    Map<String, dynamic> userlogin = conv.json.decode(response);
    return userlogin;
  }

  /// deletes saved user key and redirects user to login page
  static void logOut() async {
    await LocalStorage.removeItem(AccessService._key);
    await AccessService.deleteLastRouteRoute();
    return;
  }

  /// fetches user access details from the file system
  /// if it doesn't exist in the _userAccessCache static
  /// property
  Future<String> _fsContent() async {
    try {
      dynamic response = await LocalStorage.getItem(AccessService._key);
      if (response != false) {
        //AccessService._userAccessCache = response.toString();
        return response.toString();
      }
    } catch (e) {}
    AccessService.logOut();
    return null;
  }

  /// gets user id from the storage
  Future<String> getUserId() async {
    String fscontent = await this._fsContent();
    String userid = conv.json.decode(fscontent)["user_id"].toString();
    return userid;
  }

  /// gets accessToken from storage
  Future<String> accessToken() async {
    String fscontent = await this._fsContent();
    String access = conv.json.decode(fscontent)["token"];
    return access;
  }

  /// gets user's role from storage
  Future<String> userRole() async {
    String fscontent = await this._fsContent();
    String response = (conv.json.decode(fscontent)["role"]["id"]).toString();
    return response;
  }

  /// gets username from storage
  Future<String> getUserName() async {
    String fscontent = await this._fsContent();
    dynamic name = conv.json.decode(fscontent)["othernames"];
    String response = name == null ? "No name yet" : name;
    return response;
  }

  Future<Map<String, dynamic>> getProperty() async {
    String fscontent = await this._fsContent();
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

  Future<Map<String, String>> requestHeader() async {
    String access = await this.accessToken();
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

  Future<int> numberOfZeros(String msgStateGroup) async {
    List listOfMsgState = msgStateGroup.split("|");
    int numberOfUnread = 0;
    String userId = await this.getUserId();
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
