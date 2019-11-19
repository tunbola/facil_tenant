import "http_url_config.dart";
import "package:http/http.dart" as http;
import "dart:async";
import "dart:convert" as conv;
import "../models/http_response_model.dart";

class AuthService {
  Future<Post> userLogin(String username, String password) async {
    http.Response response = await http.post("${config["baseUrl"]}",
        headers: {}, body: {"username": username, "password": password});
    final responseJson = conv.json.decode(response.body);

    return Post.fromJson(responseJson);
  }
}
