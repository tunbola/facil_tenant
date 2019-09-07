import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:facil_tenant/models/agency_model.dart';
import 'package:facil_tenant/models/property_model.dart';

part 'agent_model.g.dart';

@JsonSerializable()
class AgentModel {
  static int itemCount = 0;
  String id;
  final String name;
  final String picture;
  final double rating;
  final String email;
  final String description;
  final String phoneNumber;
  final List<PropertyModel> properties;
  final AgencyModel agency;

  AgentModel({
    this.id,
    @required this.name,
    @required this.picture,
    @required this.rating,
    @required this.email,
    @required this.description,
    @required this.phoneNumber,
    this.properties = const [],
    @required this.agency,
  })  : assert(name != null),
        assert(picture != null),
        assert(rating != null),
        assert(email != null),
        assert(description != null),
        assert(phoneNumber != null),
        assert(agency != null) {
    AgentModel.itemCount++;
    if (id == null) {
      this.id = AgentModel.itemCount.toString();
    }
  }

  factory AgentModel.fromJson(Map<String, dynamic> json) => _$AgentModelFromJson(json);
  Map<String, dynamic> toJson() => _$AgentModelToJson(this);
}
