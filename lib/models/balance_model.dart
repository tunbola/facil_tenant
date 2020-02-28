import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:flutter/material.dart';

class BalanceModel {
  String id;
  String balance;
  String month;
  String year;
  PaymentTypeModel paymentType;

  BalanceModel(
      {this.id,
      @required this.balance,
      @required this.month,
      @required this.year,
      @required this.paymentType});
}