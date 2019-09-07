// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agency_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AgencyModel _$AgencyModelFromJson(Map<String, dynamic> json) {
  return AgencyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      rating: (json['rating'] as num)?.toDouble(),
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      properties: (json['properties'] as List)
          ?.map((e) => e == null
              ? null
              : PropertyModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      agents: (json['agents'] as List)
          ?.map((e) =>
              e == null ? null : AgentModel.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$AgencyModelToJson(AgencyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'rating': instance.rating,
      'country': instance.country,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'properties': instance.properties,
      'agents': instance.agents
    };
