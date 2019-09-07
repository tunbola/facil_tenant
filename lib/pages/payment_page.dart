import 'package:flutter/material.dart';
import '../components/app_scaffold.dart';

class PaymentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: Text("Payment Page"),
      ),
      pageTitle: ValueNotifier("PAYMENTS"),
    );
  }
}
