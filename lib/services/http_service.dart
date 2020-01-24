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

  Future<Map<String, dynamic>> fetchAnnounceMents(int pageNumber) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['announcements']}index?page=$pageNumber",
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);

      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> fetchRequests({int pageNumber, bool fetchAll}) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          fetchAll ? "${config['baseUrl']}${config['request']}${config['view']}?all=true" :"${config['baseUrl']}${config['request']}${config['view']}?page=$pageNumber",
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ...}"
      };
    }
  }

  Future<Map<String, dynamic>> fetchMessageSenders() async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['message']}",
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);

      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> fetchMessagesByTitle(String userId) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['message']}?userId=$userId",
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> fetchChatHistory(
      String chatMateId, String title) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['message']}?chatMateId=${chatMateId}&title=$title",
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> sendMessage(
      List<String> viewableBy, String title, String message) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      String requestBody = conv.json.encode(
          {"viewable_by": viewableBy, "title": title, "message": message});
      http.Response response = await http.post(
          "${config['baseUrl']}${config['message']}${config['create']}",
          body: requestBody,
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
    } catch (e) {
      return {
        "status": false,
        "message": "The application could not connect to the server ..."
      };
    }
  }

  Future<Map<String, dynamic>> updateMessagesState(String msgIds) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      String requestBody = conv.json.encode({"msgsid": msgIds});
      http.Response response = await http.put(
          "${config['baseUrl']}${config['message']}${config['update']}",
          body: requestBody,
          headers: requestHeader);
      final responseJson = conv.json.decode(response.body);
      final responseObject = ResponseModel.fromJson(responseJson);
      if (response.statusCode != 200) {
        return {"status": false, "message": responseObject.message};
      }
      return {
        "status": true,
        "message": responseObject.message,
        "data": responseObject.data
      };
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

  Future<Map<String, dynamic>> fetchRequestTypes() async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    try {
      http.Response response = await http.get(
          "${config['baseUrl']}${config['requestType']}index",
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

  Future<Map<String, dynamic>> createRequest(
      String requestTypeId, String request) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();

    try {
      String requestBody = conv.json.encode({
        "request_type_id": requestTypeId,
        "comment": request,
      });
      http.Response response = await http.post(
          "${config['baseUrl']}${config['request']}${config['create']}",
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
        "message": "Internet connection error",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> fetchOutstandingBills({String year, String month}) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    String url = "";
    try {
      if (month != null) {
        url = "${config['baseUrl']}${config['payments']}${config['outstanding']}?year=${year}&month=$month";
      } else if (year != null) {
        url = "${config['baseUrl']}${config['payments']}${config['outstanding']}?year=$year";
      } else {
        url = "${config['baseUrl']}${config['payments']}${config['outstanding']}";
      }
      http.Response response = await http.get(url, headers: requestHeader);
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
        "message": e.toString(),//"Internet connection error",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> fetchPayments({String year, String month}) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    String url = "";
    try {
      if (month != null) {
        url =  "${config['baseUrl']}${config['payments']}${config['view']}?settled=true&year=$year&month=$month";
      } else if (year != null) {
        url = "${config['baseUrl']}${config['payments']}${config['view']}?settled=true&year=$year";
      } else {
        url = "${config['baseUrl']}${config['payments']}${config['view']}?settled=true";
      }
      http.Response response = await http.get(url, headers: requestHeader);
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
        "message": "Internet connection error",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> deleteMessages(String id) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    String url = "";
    try {
        url =
            "${config['baseUrl']}${config['message']}${config['delete']}?id=$id";
      http.Response response = await http.delete(url, headers: requestHeader);
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
        "message": "Internet connection error",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> getTransactionId(String month, String year, String paymentTypeId) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    String url =
            "${config['baseUrl']}${config['transaction']}${config['create']}";
    try {
      String requestBody = conv.json.encode({
        "payment_type_id": paymentTypeId,
        "month": month,
        "year" : year
      });
      http.Response response = await http.post(url, body: requestBody, headers: requestHeader);
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
        "message": "Internet connection error",
        "data": null
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfileImage(String imageEncodedString) async {
    Map<String, String> requestHeader = await AccessService.requestHeader();
    String url =
            "${config['baseUrl']}${config['user']}${config['avatar']}";
    try {
      String requestBody = conv.json.encode({
        "user_avatar": imageEncodedString,
      });
      http.Response response = await http.put(url, body: requestBody, headers: requestHeader);
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
        "message": "Internet connection error",
        "data": null
      };
    }
  }  
}
