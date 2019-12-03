// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) {
  return UserProfileModel(
      user: json['user'] == null
          ? null
          : UserModel.fromJson(json['user'] as Map<String, dynamic>),
      property: json['property'] == null
          ? null
          : PropertyModel.fromJson(json['property'] as Map<String, dynamic>),
      visits: (json['visits'] as List)
          ?.map((e) =>
              e == null ? null : VisitModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      parentUser: json['parentUser'] == null
          ? null
          : UserModel.fromJson(json['parentUser'] as Map<String, dynamic>),
      childrenUser: (json['childUsers'] as List)
          ?.map((e) =>
              e == null ? null : UserModel.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$UserProfileModelToJson(UserProfileModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'property': instance.property,
      'visits': instance.visits,
      'parentUser': instance.parentUser,
      'childUsers': instance.childrenUser
    };
