import 'package:json_annotation/json_annotation.dart';
part 'chat_model.g.dart';

@JsonSerializable()
class ChatModel {
  String id;
  String message;
  String attachmentUrl;
  String createdAt;
  String from;

  ChatModel({
    this.id,
    this.message,
    this.createdAt,
    this.from,
    this.attachmentUrl
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) => _$ChatModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChatModelToJson(this);
}