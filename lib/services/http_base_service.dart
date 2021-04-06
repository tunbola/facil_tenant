import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:facil_tenant/services/access_service.dart';
import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;
import "http_url_config.dart";

class HttpBaseService {
  NavigationService _navigationService = locator<NavigationService>();
  final Dio dio = Dio();

  HttpBaseService() {
    dio.options.connectTimeout = 30000;
    dio.options.receiveTimeout = 45000;

    dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      if (options.headers['Authorization'] != null) {
        String token = options.headers['Authorization'].split(' ')[1];
        int currentTimeStamp =
            (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000).toInt();
        Map<String, dynamic> dt = decodeJwt(token);
        if ((dt['exp'] - currentTimeStamp) < 20) {
          //request another token
          dio.lock();
          this.keepUserIn().then((response) async {
            /*if (response == null) {
              _navigationService.navigateToReplace(routes.Auth);
              return handler.reject(DioError({requestOptions: options}), true);
              // dio.reject('Automatic log in was not completed');
            }*/
            var data = response.data;
            await AccessService.setAccess(json.encode(data['data']));
            options.headers['Authorization'] =
                "Bearer ${data['data']['token']}";
            return handler.next(options);
          }).catchError((error, stackTrace) {
            _navigationService.navigateToReplace(routes.Auth);
            handler.reject(error, true);
          }).whenComplete(() => dio.unlock());
        }
      }

      // Do something before request is sent
      return handler.next(options); //continue
      // If you want to resolve the request with some custom data，
      // you can return a `Response` object or return `dio.resolve(data)`.
      // If you want to reject the request with an error message,
      // you can return a `DioError` object or return `dio.reject(errMsg)`
    }, onResponse: (Response response, handler) async {
      // Do something with response data
      /*if (response.statusCode == 401) {
       //token expired
        _navigationService.navigateToReplace(routes.Auth);
      }*/
      return handler.next(response); // continue
    }, onError: (DioError e, handler) async {
      // Do something with response error
      /*int code = e.response.statusCode;
      if (code == 401) {
        await keepUserIn();
        //return e;
      }*/
      return handler.next(e); //continue
    }));
  }

  Map<String, dynamic> decodeJwt(String token) {
    final parts = token.split('.');
    String normalized = base64Url.normalize(parts[1]);
    String decoded = utf8.decode(base64Url.decode(normalized));
    return json.decode(decoded);
  }

  Future<Response<Map>> keepUserIn() async {
    Map<String, dynamic> userInfo = await AccessService.getLoginInfo();
    if (userInfo != null) {
      Map<String, dynamic> _body = {
        "username": userInfo['username'],
        "password": userInfo['password']
      };
      String url = "${config['baseUrl']}${config['user']}${config['login']}";
      var d = Dio();
      try {
        Response<Map> response = await d.post(url,
            data: _body,
            options: Options(headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            }));
        if (response.statusCode != 200) {
          return null;
        }
        return response;
      } catch (e) {
        return null;
      }
    }
    //_navigationService.navigateTo(routes.Home);
    return null;
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
      return {"status": false, "message": _getMessageFromError(e)};
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
      return {"status": false, "message": _getMessageFromError(e)};
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
      return {"status": false, "message": _getMessageFromError(e)};
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
      return {"status": false, "message": _getMessageFromError(e)};
    } catch (e) {
      return {
        "status": false,
        "message": "An error occured while making request"
      };
    }
  }

  /// gets error message from [error]
  ///
  /// returns an internet connection error message
  /// if it timesout, extracts the message from the
  /// response if any or returns a default error
  String _getMessageFromError(DioError error) {
    if ((error.type == DioErrorType.connectTimeout) ||
        (error.type == DioErrorType.receiveTimeout)) {
      return "Internet connection error";
    }
    //e.type = DioErrorType.DEFAULT;
    if (error.response.data is Map) {
      Map<String, dynamic> response =
          error.response.data as Map<String, dynamic>;
      if (response.containsKey('message')) {
        return response['message'];
      }
    }
    return 'Error';
  }
}
