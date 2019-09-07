import 'package:facil_tenant/mock/mock_utility.dart';
import 'package:facil_tenant/models/bill_model.dart';

final List<BillModel> bills = [
  BillModel(
    utility: utilities[0],
    isDue: true,
    isOutstanding: true,
    period: DateTime.now(),
    dueDate: DateTime.now(),
  ),
  BillModel(
    utility: utilities[1],
    isDue: false,
    isOutstanding: true,
    period: DateTime.now(),
    dueDate: DateTime.now(),
  ),
  BillModel(
    utility: utilities[2],
    isDue: true,
    isOutstanding: false,
    period: DateTime.now(),
    dueDate: DateTime.now(),
  ),
  BillModel(
    utility: utilities[3],
    isDue: true,
    isOutstanding: true,
    period: DateTime.now(),
    dueDate: DateTime.now(),
  ),
];

Future<List<BillModel>> getBills() async {
  await Future.delayed(Duration(seconds: 2));
  return Future.value(bills);
}

BillModel getBill({String id}) {
  return bills.firstWhere((it) => it.id == id);
}