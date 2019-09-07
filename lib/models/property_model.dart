import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:facil_tenant/models/agent_model.dart';
import 'package:facil_tenant/models/tenant_model.dart';

part 'property_model.g.dart';

@JsonSerializable()
class PropertyModel {
  static int itemCount = 0;
  String id;
  final String name;
  final String picture;
  final String address;
  final String city;
  final String state;
  final String country;
  final double lat;
  final double lng;
  final int apartments;
  final List<TenantModel> tenants;
  final AgentModel agent;

  PropertyModel({
    this.id,
    @required this.name,
    @required this.address,
    @required this.city,
    @required this.state,
    @required this.country,
    @required this.lat,
    @required this.lng,
    @required this.apartments,
    @required this.picture,
    this.tenants = const [],
    this.agent,
  })  : assert(name != null),
        assert(address != null),
        assert(city != null),
        assert(state != null),
        assert(country != null),
        assert(lat != null),
        assert(apartments != null),
        assert(lng != null) {
    PropertyModel.itemCount++;
    if (id == null) {
      this.id = PropertyModel.itemCount.toString();
    }
  }

  factory PropertyModel.fromJson(Map<String, dynamic> json) => _$PropertyModelFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyModelToJson(this);
}
