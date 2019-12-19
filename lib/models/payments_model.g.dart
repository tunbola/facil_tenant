// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payments_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentsModel _$PaymentsModelFromJson(Map<String, dynamic> json) {
  return PaymentsModel(
      id: json['id'] as String,
      paidOn: json['transaction']['created_at'] as String,
      year: json['year'] as String,
      month: json['month'] as String,
      paymentType: json['paymentType'] as PaymentTypeModel,
    );
}

Map<String, dynamic> _$PaymentsModelToJson(PaymentsModel instance) => <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'paymentType': instance.paymentType,
      'trasaction_date': instance.paidOn
    };
