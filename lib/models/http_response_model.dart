//This class is used as a parser for every received request from the API

class ResponseModel {
  dynamic data;
  String status;
  String message;

  ResponseModel({this.data, this.status, this.message});

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(data: json['data'], message: json['message']);
  }
}
