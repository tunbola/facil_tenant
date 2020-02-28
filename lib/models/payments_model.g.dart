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
      dueTypeId: json['due_type_id'] as String,
      paymentType: json['paymentType'] as PaymentTypeModel,
      balanceId: json['balance_id'] as String
    );
}

Map<String, dynamic> _$PaymentsModelToJson(PaymentsModel instance) => <String, dynamic>{
      'id': instance.id,
      'year': instance.year,
      'month': instance.month,
      'paymentType': instance.paymentType,
      'due_type_id': instance.dueTypeId,
      'trasaction_date': instance.paidOn,
      'balance_id': instance.balanceId
    };
