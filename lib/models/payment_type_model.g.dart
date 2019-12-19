// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentTypeModel _$PaymentTypeModelFromJson(Map<String, dynamic> json) {
  return PaymentTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as String,
      convenienceFee: json['convenience_fee'] as String,
      paymentUnit: json['payment_unit']);
}

Map<String, dynamic> _$PaymentTypeModelToJson(PaymentTypeModel instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'convenience_fee': instance.convenienceFee,
      'payment_unit': instance.paymentUnit,
    };
