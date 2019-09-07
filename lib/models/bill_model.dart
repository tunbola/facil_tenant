import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:facil_tenant/models/utility_model.dart';

part 'bill_model.g.dart';

@JsonSerializable()
class BillModel {
  static int itemCount = 0;
  String id;
  final bool isOutstanding;
  final bool isDue;
  final DateTime period;
  final DateTime dueDate;
  final UtilityModel utility;

  BillModel({
    this.id,
    @required this.isOutstanding,
    @required this.isDue,
    @required this.period,
    @required this.dueDate,
    @required this.utility,
  })  : assert(isOutstanding != null),
        assert(isDue != null),
        assert(period != null),
        assert(dueDate != null),
        assert(utility != null) {
    BillModel.itemCount++;
    if (id == null) {
      this.id = BillModel.itemCount.toString();
    }
  }

  factory BillModel.fromJson(Map<String, dynamic> json) => _$BillModelFromJson(json);
  Map<String, dynamic> toJson() => _$BillModelToJson(this);
}
