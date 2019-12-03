// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VisitModel _$VisitModelFromJson(Map<String, dynamic> json) {
  return VisitModel(
      id: json['id'] as String,
      visitorName: json['visitor_name'] as String,
      visitorPhone: json['visitor_phone'] as String,
      expectedVisitTime: json['expected_visit_time'] as String,
      createdAt: json['created_at'] as String,
      propertyId: json['property_id'] as String);
}

Map<String, dynamic> _$VisitModelToJson(VisitModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'visitor_name': instance.visitorName,
      'visitor_phone': instance.visitorPhone,
      'expected_visit_time': instance.expectedVisitTime,
      'created_at': instance.createdAt,
      'property_id': instance.propertyId
    };
