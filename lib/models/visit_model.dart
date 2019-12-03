import 'package:json_annotation/json_annotation.dart';

part 'visit_model.g.dart';

@JsonSerializable()
class VisitModel {
  final String id;
  final String visitorName;
  final String visitorPhone;
  final String expectedVisitTime;
  final String createdAt;
  final String propertyId;

  VisitModel(
      {this.id,
      this.visitorName,
      this.visitorPhone,
      this.expectedVisitTime,
      this.createdAt,
      this.propertyId});

  factory VisitModel.fromJson(Map<String, dynamic> json) =>
      _$VisitModelFromJson(json);
  Map<String, dynamic> toJson() => _$VisitModelToJson(this);
}
