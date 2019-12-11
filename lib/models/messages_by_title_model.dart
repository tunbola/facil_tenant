import 'package:json_annotation/json_annotation.dart';
part 'messages_by_title_model.g.dart';

@JsonSerializable()
class MessagesByTitleModel {
  String id;
  String title;
  String rowIdsGroup; //row_ids
  String messagesGroup ; //addedBy
  String isReadGroup; //is_read "1|1|1|1" means four messages all read seperated by |
  String sentTimeGroup; //sent_time

  MessagesByTitleModel({
    this.id,
    this.title,
    this.messagesGroup,
    this.rowIdsGroup,
    this.isReadGroup,
    this.sentTimeGroup
  });

  factory MessagesByTitleModel.fromJson(Map<String, dynamic> json) => _$MessagesByTitleModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessagesByTitleModelToJson(this);
}