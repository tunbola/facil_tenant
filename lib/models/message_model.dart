import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:facil_tenant/models/user_model.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  static int itemCount = 0;
  String id;
  final bool isRead;
  final DateTime createdAt;
  final String title;
  final String body;
  final String to;
  final UserModel from;

  MessageModel({
    this.id,
    @required this.isRead,
    @required this.createdAt,
    @required this.title,
    @required this.body,
    this.to,
    this.from,
  })  : assert(isRead != null),
        assert(createdAt != null),
        assert(title != null),
        assert(body != null) {
    MessageModel.itemCount++;
    if (id == null) {
      this.id = MessageModel.itemCount.toString();
    }
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);
  Map<String, dynamic> toJson() => _$MessageModelToJson(this);
}
