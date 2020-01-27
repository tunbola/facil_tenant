// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      parentUserId: json['parent_user_id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      surname: json['surname'] as String,
      othernames: json['othernames'] as String,
      title: json['title'] as String,
      pictureUrl: json['picture_url'] as String,
      address: json['address'] as String,
      relationship: json['relationship'] == null ? "" : json['relationship']['title']);
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'property_id': instance.propertyId,
      'parent_user_id': instance.parentUserId,
      'email': instance.email,
      'phone': instance.phone,
      'surname': instance.surname,
      'othernames': instance.othernames,
      'title': instance.title,
      'picture_url': instance.pictureUrl,
      'address': instance.address,
    };
