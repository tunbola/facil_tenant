import 'package:facil_tenant/models/utility_model.dart';

final List<UtilityModel> utilities = [
  UtilityModel(
    name: "Electricity",
    cost: 2000.0,
    description: "A utility for electricity",
  ),
  UtilityModel(
    name: "Water",
    cost: 600.0,
    description: "A utility for water",
  ),
  UtilityModel(
    name: "Security",
    cost: 800.0,
    description: "A utility for security",
  ),
  UtilityModel(
    name: "Cleaning",
    cost: 500.0,
    description: "A utility for cleaning",
  ),
  UtilityModel(
    name: "Gardening",
    cost: 200.0,
    description: "A utility for gardening",
  ),
];

Future<List<UtilityModel>> getUtilities() async {
  await Future.delayed(Duration(seconds: 2));
  return Future.value(utilities);
}

UtilityModel getUtility({String id}) {
  return utilities.firstWhere((it) => it.id == id);
}
