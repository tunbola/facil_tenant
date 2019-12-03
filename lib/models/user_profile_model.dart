import 'package:json_annotation/json_annotation.dart';
import "user_model.dart";
import "property_model.dart";
import "visit_model.dart";
part 'user_profile_model.g.dart';

@JsonSerializable()
class UserProfileModel {

  UserModel user;
  PropertyModel property;
  List<VisitModel> visits;
  UserModel parentUser;
  List<UserModel> childrenUser;
  
  UserProfileModel({this.user, this.property, this.visits, this.parentUser, this.childrenUser});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      _$UserProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileModelToJson(this);
}
