import 'package:flutter/foundation.dart';
import 'package:facil_tenant/models/tenant_model.dart';

class TenantState extends ChangeNotifier {
  List<Map<String, dynamic>> _tenants = [];
  List<TenantModel> selectedTenants = [];

  set setTenants(List<Map<String, dynamic>> tenants) {
    this._tenants = tenants;
  }

  List<TenantModel> parseTenantArray(Map<String, dynamic> args) {
    final tenants = args['tenants'];
    final key = args['key'];
    final value = args['val'];
    if (key != null) { 
      return tenants.where((inst) => inst[key] == value).map((it) => TenantModel.fromJson(it)).toList();
    } else {
      return tenants.map((it) => TenantModel.fromJson(it)).toList();
    }
  }
  
  filterTenant({String key, dynamic value}) async {
    List<TenantModel> data;
    data = await compute(parseTenantArray, {"tenants": _tenants, "key": key, "value":  value});
    selectedTenants = data;
    notifyListeners();
  }
}