import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:facil_tenant/models/payments_model.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
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

  String yearToSearch = ((DateTime.now()).year).toString();
  final choicePeriod = ValueNotifier({"year": (DateTime.now()).year});

  Future<List<PaymentsModel>> getPayments(String searchYear) async {
    Map<String, dynamic> response =
        await _httpService.fetchPayments(year: searchYear);
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
            convenienceFee: content["paymentType"]["convenience_fee"],
          )));
    }
    return Future.value(payments);
  }

  @override
  Widget build(BuildContext context) {
    formatter = NumberFormat.currency(
      name: "NGN",
      symbol: "NGN ", //
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    );
    return AppScaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: "filterHistory",
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Scaffold(
                backgroundColor: Colors.black54,
                body: SafeArea(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      // fit: StackFit.loose,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 20.0,
                            horizontal: 15.0,
                          ),
                          // alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: choicePeriod,
                            builder: (context, val, child) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Text(
                                    "Select Year",
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    height: 100,
                                    child: YearPicker(
                                      selectedDate: DateTime(val["year"]),
                                      lastDate:
                                          DateTime(DateTime.now().year + 5),
                                      firstDate:
                                          DateTime(DateTime.now().year - 5),
                                      onChanged: (valu) =>
                                          choicePeriod.value = {
                                        "year": valu.year,
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        FlatButton(
                                          onPressed: Navigator.of(context).pop,
                                          child: Text("Cancel"),
                                        ),
                                        RaisedButton(
                                          padding: EdgeInsets.all(5.0),
                                          onPressed: () {
                                            setState(() {
                                              yearToSearch =
                                                  val["year"].toString();
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("Fetch"),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: .5,
                          child: FloatingActionButton(
                            heroTag: "cls",
                            onPressed: () => Navigator.of(context).pop(),
                            child: Icon(Icons.close),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
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
                style: Theme.of(context).textTheme.headline.copyWith(
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
                future: getPayments(yearToSearch),
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
                              vertical: 15.0,
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
                                            .headline
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
                                            .headline
                                            .copyWith(fontSize: 20),
                                      ),
                                    ),
                                    Text(
                                      "Paid on : ${DateFormat.yMMMd().format(DateTime.parse(eachPayment.paidOn))}",
                                      style: Theme.of(context).textTheme.body1,
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
