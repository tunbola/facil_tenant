import 'package:json_annotation/json_annotation.dart';

part 'notifications_model.g.dart';

@JsonSerializable()
class NotificationsModel {
  String id;
  String message;
  String createdAt;
  String lastUpdated;
  String requestStatus;
  String requestType;

  NotificationsModel(
      {this.id,
      this.message,
      this.createdAt,
      this.lastUpdated,
      this.requestStatus,
      this.requestType});

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationsModelToJson(this);
}
