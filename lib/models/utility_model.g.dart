// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UtilityModel _$UtilityModelFromJson(Map<String, dynamic> json) {
  return UtilityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      cost: (json['cost'] as num)?.toDouble(),
      description: json['description'] as String);
}

Map<String, dynamic> _$UtilityModelToJson(UtilityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'cost': instance.cost,
      'description': instance.description
    };
