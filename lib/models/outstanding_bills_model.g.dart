// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outstanding_bills_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OutstandingBillsModel _$OutstandingBillsModelFromJson(
    Map<String, dynamic> json) {
  return OutstandingBillsModel(
    id: json['id'] as String,
    monthName: json['name'] as String,
    paymentTypes: (json['data'] as List)
        ?.map((e) => e == null
            ? null
            : PaymentTypeModel.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$OutstandingBillsModelToJson(
        OutstandingBillsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.monthName,
      'data': instance.paymentTypes,
    };
