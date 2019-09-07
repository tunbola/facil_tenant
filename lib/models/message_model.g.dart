// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return MessageModel(
      id: json['id'] as String,
      isRead: json['isRead'] as bool,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      title: json['title'] as String,
      body: json['body'] as String,
      to: json['to'] as String,
      from: json['from'] == null
          ? null
          : UserModel.fromJson(json['from'] as Map<String, dynamic>));
}

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt?.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'to': instance.to,
      'from': instance.from
    };
