import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'utility_model.g.dart';

@JsonSerializable()
class UtilityModel {
  static int itemCount = 0;
  String id;
  final String name;
  final double cost;
  final String description;

  UtilityModel({
    this.id,
    @required this.name,
    @required this.cost,
    @required this.description,
  })  : assert(name != null),
        assert(cost != null),
        assert(description != null) {
    UtilityModel.itemCount++;
    if (id == null) {
      this.id = UtilityModel.itemCount.toString();
    }
  }

  factory UtilityModel.fromJson(Map<String, dynamic> json) => _$UtilityModelFromJson(json);
  Map<String, dynamic> toJson() => _$UtilityModelToJson(this);
}
