// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillModel _$BillModelFromJson(Map<String, dynamic> json) {
  return BillModel(
      id: json['id'] as String,
      isOutstanding: json['isOutstanding'] as bool,
      isDue: json['isDue'] as bool,
      period: json['period'] == null
          ? null
          : DateTime.parse(json['period'] as String),
      dueDate: json['dueDate'] == null
          ? null
          : DateTime.parse(json['dueDate'] as String),
      utility: json['utility'] == null
          ? null
          : UtilityModel.fromJson(json['utility'] as Map<String, dynamic>));
}

Map<String, dynamic> _$BillModelToJson(BillModel instance) => <String, dynamic>{
      'id': instance.id,
      'isOutstanding': instance.isOutstanding,
      'isDue': instance.isDue,
      'period': instance.period?.toIso8601String(),
      'dueDate': instance.dueDate?.toIso8601String(),
      'utility': instance.utility
    };
