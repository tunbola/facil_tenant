import 'package:facil_tenant/mock/mock_facilities.dart';
import 'package:facil_tenant/models/tenant_model.dart';

final List<TenantModel> tenants = [
  TenantModel(
    name: "Ogbeni Ayalegbe",
    picture: "assets/img/tenant.png",
    residence: facilities[0],
    phoneNumber: "234 999 242 8910",
    email: "ogbeni.ayalegebe@mail.com",
  ),
  TenantModel(
    name: "Mike Ezeuogo",
    picture: "assets/img/tenant.png",
    residence: facilities[1],
    phoneNumber: "234 999 242 8910",
    email: "mike.ezeugo@mail.com",
  ),
  TenantModel(
    name: "Mercy Johnson",
    picture: "assets/img/tenant.png",
    residence: facilities[2],
    phoneNumber: "234 999 242 8910",
    email: "mercy.johnsone@mail.com",
  ),
  TenantModel(
    name: "Nga Zika",
    picture: "assets/img/tenant.png",
    residence: facilities[3],
    phoneNumber: "234 999 242 8910",
    email: "zika.nga@mail.com",
  ),
  TenantModel(
    name: "Winehouse Amy",
    picture: "assets/img/tenant.png",
    residence: facilities[4],
    phoneNumber: "234 999 242 8910",
    email: "amy.winehouse@mail.com",
  ),
];

Future<List<TenantModel>> getTenants({String propertyName}) async {
  await Future.delayed(Duration(seconds: 2));
  return Future.value(
    propertyName != null
        ? tenants.where((it) => it.residence.name == propertyName).toList()
        : tenants,
  );
}

TenantModel getTenant({String id}) {
  return tenants.firstWhere((it) => it.id == id);
}
