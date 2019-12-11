// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'messages_by_title_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessagesByTitleModel _$MessagesByTitleModelFromJson(Map<String, dynamic> json) {
  return MessagesByTitleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      messagesGroup: json['msg'] as String,
      isReadGroup: json['is_read'] as String,
      sentTimeGroup: json['sent_time'] as String,
      rowIdsGroup: json['row_ids'] as String);
}

Map<String, dynamic> _$MessagesByTitleModelToJson(MessagesByTitleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'msg': instance.messagesGroup,
      'is_read': instance.isReadGroup,
      'sent_time': instance.sentTimeGroup,
      'row_ids': instance.rowIdsGroup
    };
