import 'package:dio/dio.dart';
import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

class HttpBaseService {
  Dio dio = new Dio();
  NavigationService _navigationService = locator<NavigationService>();

  HttpBaseService() {
    dio.options.connectTimeout = 30000;
    dio.options.receiveTimeout = 45000;
  }

  Future<Map<String, dynamic>> sendGet(
      String url, Map<String, dynamic> requestHeader) async {
    try {
      Response<Map> response =
          await this.dio.get(url, options: Options(headers: requestHeader));
      final responseJson = response.data;
      if (response.statusCode != 200)
        return {"status": false, "message": responseJson["message"]};
      return {
        "status": true,
        "message": responseJson["message"],
        "data": responseJson["data"]
      };
    } on DioError catch (e) {
      if ((e.type == DioErrorType.CONNECT_TIMEOUT) ||
          (e.type == DioErrorType.RECEIVE_TIMEOUT)) {
        return {"status": false, "message": "Internet connection errorer"};
      }
      //e.type = DioErrorType.DEFAULT;
      return {"status": false, "message": 'An error occured'};
    } catch (e) {
      return {
        "status": false,
        "message": "An error occured while making request"
      };
    }
  }

  Future<Map<String, dynamic>> sendPost(
      String url, dynamic body, Map<String, dynamic> requestHeader) async {
    try {
      Response<Map> response = await this
          .dio
          .post(url, data: body, options: Options(headers: requestHeader));
      final responseJson = response.data;
      if (response.statusCode != 200)
        return {"status": false, "message": responseJson["message"]};
      return {
        "status": true,
        "message": responseJson["message"],
        "data": responseJson["data"]
      };
    } on DioError catch (e) {
      if ((e.type == DioErrorType.CONNECT_TIMEOUT) ||
          (e.type == DioErrorType.RECEIVE_TIMEOUT)) {
        return {"status": false, "message": "Internet connection errorer"};
      }
      //e.type = DioErrorType.DEFAULT;
      return {"status": false, "message": 'An error occured'};
    } catch (e) {
      return {
        "status": false,
        "message": "An error occured while making request"
      };
    }
  }

  Future<Map<String, dynamic>> sendDelete(
      String url, Map<String, dynamic> requestHeader) async {
    try {
      Response<Map> response =
          await this.dio.delete(url, options: Options(headers: requestHeader));
      final responseJson = response.data;
      if (response.statusCode != 200)
        return {"status": false, "message": responseJson["message"]};
      return {
        "status": true,
        "message": responseJson["message"],
        "data": responseJson["data"]
      };
    } on DioError catch (e) {
      if ((e.type == DioErrorType.CONNECT_TIMEOUT) ||
          (e.type == DioErrorType.RECEIVE_TIMEOUT)) {
        return {"status": false, "message": "Internet connection errorer"};
      }
      //e.type = DioErrorType.DEFAULT;
      return {"status": false, "message": 'An error occured'};
    } catch (e) {
      return {
        "status": false,
        "message": "An error occured while making request"
      };
    }
  }

  Future<Map<String, dynamic>> sendPut(
      String url, dynamic body, Map<String, dynamic> requestHeader) async {
    try {
      Response<Map> response = await this
          .dio
          .put(url, data: body, options: Options(headers: requestHeader));
      final responseJson = response.data;
      if (response.statusCode != 200)
        return {"status": false, "message": responseJson["message"]};
      return {
        "status": true,
        "message": responseJson["message"],
        "data": responseJson["data"]
      };
    } on DioError catch (e) {
      if ((e.type == DioErrorType.CONNECT_TIMEOUT) ||
          (e.type == DioErrorType.RECEIVE_TIMEOUT)) {
        return {"status": false, "message": "Internet connection errorer"};
      }
      //e.type = DioErrorType.DEFAULT;
      return {"status": false, "message": 'An error occured'};
    } catch (e) {
      return {
        "status": false,
        "message": "An error occured while making request"
      };
    }
  }
}
