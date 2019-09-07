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
      city: json['city'] as String,
      state: json['state'] as String,
      country: json['country'] as String,
      lat: (json['lat'] as num)?.toDouble(),
      lng: (json['lng'] as num)?.toDouble(),
      apartments: json['apartments'] as int,
      picture: json['picture'] as String,
      tenants: (json['tenants'] as List)
          ?.map((e) => e == null
              ? null
              : TenantModel.fromJson(e as Map<String, dynamic>))
          ?.toList(),
      agent: json['agent'] == null
          ? null
          : AgentModel.fromJson(json['agent'] as Map<String, dynamic>));
}

Map<String, dynamic> _$PropertyModelToJson(PropertyModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'lat': instance.lat,
      'lng': instance.lng,
      'apartments': instance.apartments,
      'tenants': instance.tenants,
      'agent': instance.agent
    };
