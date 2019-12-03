// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationsModel _$NotificationsModelFromJson(Map<String, dynamic> json) {
  return NotificationsModel(
    id: json['id'] as String,
    message: json['message'] as String,
    createdAt: json['created_at'] as String,
    lastUpdated: json['last_updated'] as String,
    requestStatus: json['requestStatus']['name'] as String,
    requestType: json['requestType']['name'] as String
  );
}

Map<String, dynamic> _$NotificationsModelToJson(NotificationsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'created_at': instance.createdAt,
      'last_updated': instance.lastUpdated,
      'requestStatus': instance.requestStatus,
      'requestType': instance.requestType
    };
