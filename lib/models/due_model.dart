class DueModel {
  String id;
  String name;

  DueModel({this.id, this.name});

  factory DueModel.fromJson(Map<String, dynamic> json) {
    return DueModel(id: json['id'], name: json['name']);
  }
}