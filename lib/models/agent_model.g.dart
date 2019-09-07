// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agent_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgentModel _$AgentModelFromJson(Map<String, dynamic> json) {
  return AgentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      picture: json['picture'] as String,
      rating: (json['rating'] as num)?.toDouble(),
      email: json['email'] as String,
      description: json['description'] as String,
      phoneNumber: json['phoneNumber'] as String,
      properties: (json['properties'] as List)
          ?.map((e) => e == null
              ? null
              : PropertyModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      agency: json['agency'] == null
          ? null
          : AgencyModel.fromJson(json['agency'] as Map<String, dynamic>));
}

Map<String, dynamic> _$AgentModelToJson(AgentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'rating': instance.rating,
      'email': instance.email,
      'description': instance.description,
      'phoneNumber': instance.phoneNumber,
      'properties': instance.properties,
      'agency': instance.agency
    };
