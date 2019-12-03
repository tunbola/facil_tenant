// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyModel _$PropertyModelFromJson(Map<String, dynamic> json) {
  return PropertyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      stateId: json['state_id'] as String);
}

Map<String, dynamic> _$PropertyModelToJson(PropertyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'state_id': instance.stateId
    };
