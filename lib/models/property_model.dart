import 'package:json_annotation/json_annotation.dart';

part 'property_model.g.dart';

@JsonSerializable()
class PropertyModel {
  String id;
  String name;
  String address;
  String stateId;

  PropertyModel({this.id, this.name, this.address, this.stateId});

  factory PropertyModel.fromJson(Map<String, dynamic> json) =>
      _$PropertyModelFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
}
