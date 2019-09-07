// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      picture: json['picture'] as String,
      email: json['email'] as String,
      phoneNumber: json['phoneNumber'] as String,
      type: _$enumDecodeNullable(_$UserTypeEnumMap, json['type']));
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'picture': instance.picture,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
      'type': _$UserTypeEnumMap[instance.type]
    };

T _$enumDecode<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }
  return enumValues.entries
      .singleWhere((e) => e.value == source,
          orElse: () => throw ArgumentError(
              '`$source` is not one of the supported values: '
              '${enumValues.values.join(', ')}'))
      .key;
}

T _$enumDecodeNullable<T>(Map<T, dynamic> enumValues, dynamic source) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source);
}

const _$UserTypeEnumMap = <UserType, dynamic>{
  UserType.AGENT: 'AGENT',
  UserType.TENANT: 'TENANT'
};
