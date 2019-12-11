// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'received_messages_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceivedMessagesModel _$ReceivedMessagesModelFromJson(Map<String, dynamic> json) {
  return ReceivedMessagesModel(
      id: json['id'] as String,
      title: json['msg_title'] as String,
      messagesGroup: json['row_ids'] as String,
      isReadGroup: json['is_read'] as String,
      sentTimeGroup: json['sent_time'] as String,
      sender: json['addedBy'] == null
          ? null
          : UserModel.fromJson(json['addedBy'] as Map<String, dynamic>));
}

Map<String, dynamic> _$ReceivedMessagesModelToJson(ReceivedMessagesModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'msg_title': instance.title,
      'row_ids': instance.messagesGroup,
      'is_read': instance.isReadGroup,
      'sent_time': instance.sentTimeGroup,
      'addedBy': instance.sender
    };
