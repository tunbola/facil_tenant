import "http_url_config.dart";
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert" as conv;
import "../models/http_response_model.dart";

import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

import "package:facil_tenant/services/access_service.dart";

class AuthService {
  static NavigationService _navigationService = locator<NavigationService>();

  Future<String> userLogin(String username, String password) async {
    try {
      http.Response response = await http.post(
          "${config['baseUrl']}${config['user']}${config['login']}",
          body: {"username": username, "password": password});
      final responseJson = conv.json.decode(response.body);

      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return responseObject.message;
      }
      //save access token and other information
      AccessService.setAccess(conv.json.encode(responseObject.data));
      _navigationService.navigateTo(routes.Home);
      return null;
    } catch (e) {
      return "The application could not connect to the server ...";
    }
  }

  fetchAnnounceMents(String propertyId, String pageNumber) async {
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['anouncements']}index?id=${propertyId}&page=${pageNumber}");
      final responseJson = conv.json.decode(response.body);

      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return responseObject.data;
      }
      return responseObject.message;
    } catch (e) {
      return "The application could not connect to the server ...";
    }
  }

  fetchMessagesTrail() async {
    String userId = await AccessService.userId;
    try {
      http.Response response = await http
          .get("${config['baseUrl']}${config['anouncements']}index?id=$userId");
      final responseJson = conv.json.decode(response.body);

      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return responseObject.data;
      }
      return responseObject.message;
    } catch (e) {
      return "The application could not connect to the server ...";
    }
  }

  Future<Map<String, dynamic>> registerUser(String phone, String email, String password, String smsCode) async {
    try {
      http.Response response = await http.post(
          "${config['baseUrl']}${config['user']}${config['create']}",
          body: {"phone": phone, "email": email, "password": password, "sms_code": smsCode});
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message" : responseObject.message};
      }
      return {"status": true, "message" : responseObject.message};
    } catch (e) {
      return {"status": false, "message" : "The application could not connect to the server ..."};
    }
  }
}
