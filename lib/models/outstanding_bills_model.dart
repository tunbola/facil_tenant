import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'outstanding_bills_model.g.dart';

@JsonSerializable()
class OutstandingBillsModel {
  String id;
  final String monthName;
  final List<PaymentTypeModel> paymentTypes;

  OutstandingBillsModel({
    this.id,
    @required this.monthName,
    @required this.paymentTypes,
  })  : assert(monthName != null),
        assert(paymentTypes != null);

  factory OutstandingBillsModel.fromJson(Map<String, dynamic> json) => _$OutstandingBillsModelFromJson(json);
  Map<String, dynamic> toJson() => _$OutstandingBillsModelToJson(this);
}
