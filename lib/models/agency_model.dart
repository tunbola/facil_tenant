import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:facil_tenant/models/agent_model.dart';
import 'package:facil_tenant/models/property_model.dart';

part 'agency_model.g.dart';

@JsonSerializable()
class AgencyModel {
  static int itemCount = 0;
  String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final double rating;
  final String country;
  final String email;
  final String phoneNumber;
  final List<PropertyModel> properties;
  final List<AgentModel> agents;

  AgencyModel({
    this.id,
    @required this.name,
    @required this.address,
    @required this.rating,
    @required this.city,
    @required this.state,
    @required this.country,
    @required this.email,
    @required this.phoneNumber,
    this.properties = const [],
    this.agents = const [],
  })  : assert(name != null),
        assert(address != null),
        assert(city != null),
        assert(state != null),
        assert(rating != null),
        assert(country != null),
        assert(email != null),
        assert(phoneNumber != null) {
    AgencyModel.itemCount++;
    if (id == null) {
      this.id = AgencyModel.itemCount.toString();
    }
  }

  factory AgencyModel.fromJson(Map<String, dynamic> json) => _$AgencyModelFromJson(json);
  Map<String, dynamic> toJson() => _$AgencyModelToJson(this);
}
