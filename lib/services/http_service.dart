//import 'package:facil_tenant/models/index.dart';
import 'package:facil_tenant/services/http_base_service.dart';

import "http_url_config.dart";
import "dart:async";
import "dart:convert" as conv;

import "package:facil_tenant/services/access_service.dart";

class HttpService {
  HttpBaseService requestHander = HttpBaseService();

  final AccessService accessService = new AccessService();

  Map<String, String> beforeLoginHeader = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Future<Map<String, dynamic>> userLogin(
      String username, String password) async {
    Map<String, dynamic> _body = {"username": username, "password": password};
    String url = "${config['baseUrl']}${config['user']}${config['login']}";
    Map<String, dynamic> response =
        await requestHander.sendPost(url, _body, beforeLoginHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchAnnounceMents(int pageNumber) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url =
        "${config['baseUrl']}${config['announcements']}index?page=$pageNumber";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchRequests(
      {int pageNumber, bool fetchAll = false}) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = fetchAll
        ? "${config['baseUrl']}${config['request']}${config['view']}?all=true"
        : "${config['baseUrl']}${config['request']}${config['view']}?page=$pageNumber";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchMessageSenders() async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['message']}";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchMessagesByTitle(String userId) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['message']}?userId=$userId";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchChatHistory(
      String chatMateId, String title) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url =
        "${config['baseUrl']}${config['message']}?chatMateId=${chatMateId}&title=$title";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> sendMessage(
      List<String> viewableBy, String title,
      {String message, String attachment}) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String requestBody = conv.json.encode({
      "viewable_by": viewableBy,
      "title": title,
      "message": message,
      "attachment": attachment
    });
    String url = "${config['baseUrl']}${config['message']}${config['create']}";
    Map<String, dynamic> response =
        await requestHander.sendPost(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> updateMessagesState(String msgIds) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String requestBody = conv.json.encode({"msgsid": msgIds});
    String url = "${config['baseUrl']}${config['message']}${config['update']}";
    Map<String, dynamic> response =
        await requestHander.sendPut(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> registerUser(
      String phone, String email, String password, String smsCode) async {
    Map<String, dynamic> payload = {
      "phone": phone,
      "email": email,
      "password": password,
      "sms_code": smsCode
    };
    String url = "${config['baseUrl']}${config['user']}${config['create']}";
    Map<String, dynamic> response =
        await requestHander.sendPost(url, payload, null);
    return response;
  }

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url =
        "${config['baseUrl']}${config['user']}${config['view']}?id=$userId";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> createDependentUser(
      String phone, String dependent) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String requestBody =
        conv.json.encode({"phone": phone, "dependent_id": dependent});
    String url = "${config['baseUrl']}${config['register']}${config['create']}";
    Map<String, dynamic> response =
        await requestHander.sendPost(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> registerVisit(
      String visitorName, String visitorPhone, String expectedVisitTime) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String requestBody = conv.json.encode({
      "visitor_name": visitorName,
      "visitor_phone": visitorPhone,
      "expected_visit_time": expectedVisitTime
    });
    String url = "${config['baseUrl']}${config['visit']}${config['create']}";
    Map<String, dynamic> response =
        await requestHander.sendPost(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> updateProfile(String surname, String othernames,
      String phone, String email, String address, String title) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String userId = await this.accessService.getUserId();
    String requestBody = conv.json.encode({
      "surname": surname,
      "othernames": othernames,
      "phone": phone,
      "email": email,
      "address": address,
      "title": title,
      "id": userId
    });
    String url =
        "${config['baseUrl']}${config['user']}${config['update']}?id=$userId";
    Map<String, dynamic> response =
        await requestHander.sendPut(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchRequestTypes() async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['requestType']}index";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> createRequest(
      String requestTypeId, String request,
      {String attachment}) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['request']}${config['create']}";
    String requestBody = attachment == null
        ? conv.json.encode({
            "request_type_id": requestTypeId,
            "comment": request,
          })
        : conv.json.encode({
            "request_type_id": requestTypeId,
            "comment": request,
            "attachment": attachment
          });
    Map<String, dynamic> response =
        await requestHander.sendPost(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchOutstandingBills(
      {String year, String month}) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "";
    if (month != null) {
      url =
          "${config['baseUrl']}${config['payments']}${config['outstanding']}?year=${year}&month=$month";
    } else if (year != null) {
      url =
          "${config['baseUrl']}${config['payments']}${config['outstanding']}?year=$year";
    } else {
      url = "${config['baseUrl']}${config['payments']}${config['outstanding']}";
    }
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchBalances() async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['balances']}${config['view']}";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchPayments(
      {String year, String month}) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "";
    if (month != null) {
      url =
          "${config['baseUrl']}${config['payments']}${config['view']}?settled=true&year=$year&month=$month";
    } else if (year != null) {
      url =
          "${config['baseUrl']}${config['payments']}${config['view']}?settled=true&year=$year";
    } else {
      url =
          "${config['baseUrl']}${config['payments']}${config['view']}?settled=true";
    }
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> deleteMessages(String id) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url =
        "${config['baseUrl']}${config['message']}${config['delete']}?id=$id";
    Map<String, dynamic> response =
        await requestHander.sendDelete(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> getTransactionId(
      List<Map<String, dynamic>> paymentData) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url =
        "${config['baseUrl']}${config['transaction']}${config['create']}";
    String requestBody = conv.json.encode({"payment_info": paymentData});
    Map<String, dynamic> response =
        await requestHander.sendPost(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> uploadProfileImage(
      String imageEncodedString) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['user']}${config['avatar']}";
    String requestBody = conv.json.encode({
      "user_avatar": imageEncodedString,
    });
    Map<String, dynamic> response =
        await requestHander.sendPut(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchDependents() async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['dependents']}index";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> updateRequest(String id, String message,
      {String attachment}) async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['request']}edit";
    String requestBody = attachment == null
        ? conv.json.encode({
            "id": id,
            "comment": message,
          })
        : conv.json
            .encode({"id": id, "comment": message, "attachment": attachment});
    Map<String, dynamic> response =
        await requestHander.sendPut(url, requestBody, requestHeader);
    return response;
  }

  Future<Map<String, dynamic>> fetchDuePaymentTypes() async {
    Map<String, String> requestHeader =
        await this.accessService.requestHeader();
    String url = "${config['baseUrl']}${config['duetypes']}";
    Map<String, dynamic> response =
        await requestHander.sendGet(url, requestHeader);
    return response;
  }
}
