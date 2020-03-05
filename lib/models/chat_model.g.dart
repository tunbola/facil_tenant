// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatModel _$ChatModelFromJson(Map<String, dynamic> json) {
  return ChatModel(
      id: json['id'] as String,
      message: json['message'] as String,
      createdAt: json['created_at'] as String,
      attachmentUrl: json['attachment_url'],
      from: json['added_by'] as String);
}

Map<String, dynamic> _$ChatModelToJson(ChatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'message': instance.message,
      'created_at': instance.createdAt,
      'added_by': instance.from,
      'attachment_url': instance.attachmentUrl
    };
