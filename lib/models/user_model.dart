import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String propertyId;
  final String parentUserId;
  final String email;
  final String phone;
  final String surname;
  final String othernames;
  final String title;
  final String pictureUrl;
  final String address;
  final String relationship;
  UserModel(
      {this.id,
      this.propertyId,
      this.parentUserId,
      this.email,
      this.phone,
      this.surname,
      this.othernames,
      this.title,
      this.pictureUrl,
      this.address, this.relationship});
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
