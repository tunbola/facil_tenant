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
  static setAccess(String userDetails) {
    LocalStorage.setItem(AccessService._key, userDetails).then((response) {
      return true;
    }).catchError((error){
      return false;
    });
  }

  /// deletes saved user key and redirects user to login page
  static void logOut() {
    LocalStorage.removeItem(AccessService._key);
    AccessService._navigationService.navigateTo(routes.Auth);
  }

  /// fetches user access details from the file system
  /// if it doesn't exist in the _userAccessCache static
  /// property
  static _fsContent() async {
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

  /// gets user id from the storage
  static Future<String> get userId async {
    String fscontent = await AccessService._fsContent();
    String userid = conv.json.decode(fscontent)["user_id"];
    return userid;
  }

  /// gets accessToken from storage
  static String get accessToken {
    return conv.json.decode(AccessService._fsContent())["token"];
  }

  /// gets user's role from storage
  static String get userRole {
    return conv.json.decode(AccessService._fsContent())["role"]["name"];
  }

  /// gets username from storage
  static get userName async {
    String fscontent = await AccessService._fsContent();
    return conv.json.decode(fscontent)["othernames"];
  }

  static Future<Map<String, dynamic>> get property async {
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
    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
    return emailValid;
  }

}