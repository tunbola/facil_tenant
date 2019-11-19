//This class is used as a parser for every received request from the API
class Post {
  Map<String, dynamic> data;
  String status;
  String message;

  Post({this.data, this.status, this.message});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      data: json['data'],
      message: json['message']
    );
  }
}