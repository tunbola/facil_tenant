import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'bill_model.dart';
import 'property_model.dart';

part 'tenant_model.g.dart';

@JsonSerializable()
class TenantModel {
  static int itemCount = 0;
  String id;
  final String name;
  final String picture;
  final String email;
  final String phoneNumber;
  final PropertyModel residence;
  final List<BillModel> bills;

  TenantModel({
    this.id,
    @required this.name,
    @required this.picture,
    @required this.email,
    @required this.phoneNumber,
    @required this.residence,
    this.bills = const [],
  })  : assert(name != null),
        assert(picture != null),
        assert(email != null),
        assert(residence != null),
        assert(phoneNumber != null) {
    TenantModel.itemCount++;
    if (id == null) {
      this.id = TenantModel.itemCount.toString();
    }
  }

  factory TenantModel.fromJson(Map<String, dynamic> json) => _$TenantModelFromJson(json);
  Map<String, dynamic> toJson() => _$TenantModelToJson(this);
}
