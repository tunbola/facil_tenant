//import 'package:facil_tenant/models/index.dart';
import "http_url_config.dart";
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert" as conv;
import "../models/http_response_model.dart";

import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

import "package:facil_tenant/services/access_service.dart";

class HttpService {
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
      bool access =
          await AccessService.setAccess(conv.json.encode(responseObject.data));
      if (access) {
        _navigationService.navigateTo(routes.Home);
        return null;
      }
      return "Application error";
    } catch (e) {
      return "The application could not connect to the server ...";
    }
  }

  Future<Map<String, dynamic>>fetchAnnounceMents(String pageNumber) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['announcements']}index?page=$pageNumber", headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);

      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {"status": true, "message": responseObject.message, "data": responseObject.data};
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>>fetchRequests(String pageNumber) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['request']}${config['view']}?page=$pageNumber", headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {"status": true, "message": responseObject.message, "data": responseObject.data};
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ... ${e.toString()}"
      };
    }
  }

  fetchMessagesTrail(String userId) async {
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
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> registerUser(
      String phone, String email, String password, String smsCode) async {
    try {
      http.Response response = await http.post(
          "${config['baseUrl']}${config['user']}${config['create']}",
          body: {
            "phone": phone,
            "email": email,
            "password": password,
            "sms_code": smsCode
          });
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {"status": true, "message": responseObject.message};
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['user']}${config['view']}?id=$userId",
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {
          "status": false,
          "message": responseObject.message,
          "data": null
        };
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ...",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> createDependentUser(String phone) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      String requestBody = conv.json.encode({"phone": phone});
      http.Response response = await http.post(
          "${config['baseUrl']}${config['register']}${config['create']}",
          body: requestBody,
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {
          "status": false,
          "message": responseObject.message,
          "data": null
        };
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {"status": false, "message": e.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> registerVisit(
      String visitorName, String visitorPhone, String expectedVisitTime) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      String requestBody = conv.json.encode({
        "visitor_name": visitorName,
        "visitor_phone": visitorPhone,
        "expected_visit_time": expectedVisitTime
      });
      http.Response response = await http.post(
          "${config['baseUrl']}${config['visit']}${config['create']}",
          body: requestBody,
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200)
        return {
          "status": false,
          "message": responseObject.message,
          "data": null
        };
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "Error occured white registering your visit schedule",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile(String surname, String othernames,
      String phone, String email, String address, String title) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    String userId = await AccessService.getUserId();
    try {
      String requestBody = conv.json.encode({
        "surname": surname,
        "othernames": othernames,
        "phone": phone,
        "email": email,
        "address": address,
        "title": title,
        "id": userId
      });
      http.Response response = await http.put(
          "${config['baseUrl']}${config['user']}${config['update']}?id=$userId",
          body: requestBody,
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200)
        return {
          "status": false,
          "message": responseObject.message,
          "data": null
        };
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "Failed to update your profile",
        "data": null
      };
    }
  }
}
