import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';

import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:facil_tenant/models/payments_model.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import '../components/app_scaffold.dart';

const Months = const [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

NumberFormat formatter;

class PaymentHistoryPage extends StatefulWidget {
  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final _httpService = HttpService();

  DateTime initialDate = DateTime.now();
  DateTime selectedDate = DateTime.now();

  String yearToSearch = ((DateTime.now()).year).toString();
  String monthToSearch = "00";
  Map<String, String> monthsMap = {
    "All": "00",
    "January": "01",
    "February": "02",
    "March": "03",
    "April": "04",
    "May": "05",
    "June": "06",
    "July": "07",
    "August": "08",
    "September": "09",
    "October": "10",
    "November": "11",
    "December": "12"
  };
  static String _getYearsRange() {
    int _startPoint = 2018;
    int _endPoint = DateTime.now().year + 2;
    List<String> _years = [];
    for (int i = _startPoint; i <= _endPoint; i++) {
      _years.add(i.toString());
    }
    return "$_years";
  }

  String pickerData2 = '''[
    ${_PaymentHistoryPageState._getYearsRange()},
    [
      "All",
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ]
  ]
  ''';

  Future<List<PaymentsModel>> getPayments(
      String searchYear, String monthSearch) async {
    Map<String, dynamic> response = monthSearch == monthsMap["All"]
        ? await _httpService.fetchPayments(year: searchYear)
        : await _httpService.fetchPayments(
            year: searchYear, month: monthSearch);
    List<PaymentsModel> payments = [];
    for (var i = 0; i < response["data"].length; i++) {
      Map<String, dynamic> content = response["data"][i];
      payments.add(PaymentsModel(
          id: content["id"],
          year: content["year"],
          month: content["month"],
          paidOn: content["transaction"]["created_at"],
          paymentType: PaymentTypeModel(
            id: content["paymentType"]["id"],
            name: content["paymentType"]["name"],
            paymentUnit: content["paymentType"]["payment_unit"],
            amount: content["paymentType"]["amount"],
          )));
    }
    return Future.value(payments);
  }

  @override
  Widget build(BuildContext context) {
    formatter = NumberFormat.currency(
      name: "NGN",
      symbol: "NGN ",
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    );
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "filterHistory",
        onPressed: () {
          Picker(
              adapter: PickerDataAdapter<String>(
                  pickerdata: new JsonDecoder().convert(pickerData2),
                  isArray: true),
              hideHeader: true,
              title: new Text(
                "Select year & month",
                style: TextStyle(color: shedAppBlue400),
              ),
              onConfirm: (Picker picker, List value) {
                List<dynamic> values = picker.getSelectedValues();
                setState(() {
                  yearToSearch = values[0];
                  monthToSearch = monthsMap[values[1]];
                });
              }).showDialog(context);
        },
        child: Icon(
          Icons.calendar_today,
        ),
      ),
      child: Container(
        padding: EdgeInsets.only(
          top: 10.0,
          left: 16.0,
          right: 16.0,
        ),
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: shedAppBlue300,
              ),
              child: Text(
                "Showing Bill Payments for $yearToSearch",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5.copyWith(
                      fontSize: 16,
                      color: Colors.white,
                    ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: FutureBuilder(
                future: getPayments(yearToSearch, monthToSearch),
                builder: (context, res) {
                  if (res.hasError) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/img/empty_state.png'),
                        ),
                      ),
                    );
                  }
                  if (res.hasData) {
                    if (res.data.length <= 0) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/no_messages.png'),
                          ),
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 90.0),
                            child: Text(
                              "No payments found for this period",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: res.data.length,
                      itemBuilder: (context, idx) {
                        final PaymentsModel eachPayment = res.data[idx];
                        return Card(
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "${eachPayment.paymentType.name}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(fontSize: 20),
                                      ),
                                    ),
                                    Text(
                                      "Paid for : ${Months[int.parse(eachPayment.month) - 1]}",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "${formatter.format(double.parse(eachPayment.paymentType.amount))}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline5
                                            .copyWith(fontSize: 20),
                                      ),
                                    ),
                                    Text(
                                      "Paid on : ${DateFormat.yMMMd().format(DateTime.parse(eachPayment.paidOn))}",
                                      style:
                                          Theme.of(context).textTheme.caption,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, idx) => Container(
                        height: 0.5,
                        color: Colors.grey,
                      ),
                    );
                  } else {
                    return AppSpinner();
                  }
                },
              ),
            ),
          ],
        ),
      ),
      pageTitle: ValueNotifier("PAYMENT HISTORY"),
    );
  }
}
