import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserType {
  AGENT,
  TENANT
}

@JsonSerializable()
class UserModel {
  static int itemCount = 0;
  String id;
  final String name;
  final String picture;
  final String email;
  final String phoneNumber;
  final UserType type;

  UserModel({
    this.id,
    @required this.name,
    @required this.picture,
    @required this.email,
    @required this.phoneNumber,
    @required this.type,
  })  : assert(name != null),
        assert(picture != null),
        assert(email != null),
        assert(phoneNumber != null),
        assert(type != null) {
    UserModel.itemCount++;
    if (id == null) {
      this.id = UserModel.itemCount.toString();
    }
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
