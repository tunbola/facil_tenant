import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payment_type_model.g.dart';

@JsonSerializable()
class PaymentTypeModel {
  String id;
  final String name;
  final String amount;
  final String convenienceFee;
  final String paymentUnit;

  PaymentTypeModel({
    this.id,
    @required this.name,
    @required this.amount,
    @required this.convenienceFee,
    @required this.paymentUnit,
  })  : assert(name != null),
        assert(amount != null),
        assert(convenienceFee != null),
        assert(paymentUnit != null){
  }

  factory PaymentTypeModel.fromJson(Map<String, dynamic> json) => _$PaymentTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentTypeModelToJson(this);
}
