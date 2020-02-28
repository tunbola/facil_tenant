import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_type_model.g.dart';

@JsonSerializable()
class PaymentTypeModel {
  String uniqueKey;
  String id;
  final String name;
  String amount;
  final String paymentUnit;
  final String fixedPayment;

  PaymentTypeModel({
    this.uniqueKey,
    this.id,
    this.fixedPayment,
    @required this.name,
    @required this.amount,
    @required this.paymentUnit,
  })  : assert(name != null),
        assert(amount != null),
        assert(paymentUnit != null){
  }

  factory PaymentTypeModel.fromJson(Map<String, dynamic> json) => _$PaymentTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentTypeModelToJson(this);
}
