import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payments_model.g.dart';

@JsonSerializable()
class PaymentsModel {
  String id;
  final String year;
  final String month;
  final String paidOn;
  final PaymentTypeModel paymentType;

  PaymentsModel({
    this.id,
    this.paidOn,
    @required this.year,
    @required this.month,
    @required this.paymentType,
  })  : assert(year != null),
        assert(month != null),
        assert(paymentType != null);

  factory PaymentsModel.fromJson(Map<String, dynamic> json) => _$PaymentsModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentsModelToJson(this);
}
