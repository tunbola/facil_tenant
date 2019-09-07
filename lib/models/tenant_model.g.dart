// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tenant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TenantModel _$TenantModelFromJson(Map<String, dynamic> json) {
  return TenantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      picture: json['picture'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      residence: json['residence'] == null
          ? null
          : PropertyModel.fromJson(json['residence'] as Map<String, dynamic>),
      bills: (json['bills'] as List)
          ?.map((e) =>
              e == null ? null : BillModel.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

Map<String, dynamic> _$TenantModelToJson(TenantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'residence': instance.residence,
      'bills': instance.bills
    };
