import 'package:json_annotation/json_annotation.dart';
import 'package:facil_tenant/models/user_model.dart';

part 'received_messages_model.g.dart';

@JsonSerializable()
class ReceivedMessagesModel {
  String id;
  String title;
  String messagesGroup; //row_ids
  UserModel sender; //addedBy
  String isReadGroup; //is_read "1|1|1|1" means four messages all read seperated by |
  String sentTimeGroup; //sent_time

  ReceivedMessagesModel({
    this.id,
    this.title,
    this.messagesGroup,
    this.sender,
    this.isReadGroup,
    this.sentTimeGroup
  });

  factory ReceivedMessagesModel.fromJson(Map<String, dynamic> json) => _$ReceivedMessagesModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReceivedMessagesModelToJson(this);
}
