import "package:facil_tenant/services/storage_service.dart";
import "dart:convert" as conv;

import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

class AccessService {
  static final String _key = "FacilAccessKey";
  static String _userAccessCache = "";
  static NavigationService _navigationService = locator<NavigationService>();

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

  /// deletes saved user key and redirects user to login page
  static void logOut() async{
    await LocalStorage.removeItem(AccessService._key);
    AccessService.clearCache();
    AccessService._navigationService.navigateTo(routes.Auth);
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
    String response = conv.json.decode(fscontent)["role"]["name"];
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

  static Future<Map<String, String>> requestHeader() async{
    String access = await AccessService.accessToken(); 
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Authorization": "Bearer $access"
    };
  }
}
