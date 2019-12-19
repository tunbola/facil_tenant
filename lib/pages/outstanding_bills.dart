import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/mock/mock_payments.dart';
import 'package:facil_tenant/models/bill_model.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
import '../components/app_scaffold.dart';

/*const Months = const [
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
];*/

NumberFormat formatter;
List<BillModel> _bills;

class OutstandingBillsPage extends StatelessWidget {
  final ValueNotifier _isPaying = ValueNotifier(false);

  Future<bool> _processPayment() async {
    _isPaying.value = true;
    await Future.delayed(
      Duration(seconds: 3),
    );
    return Future.value(true);
  }

  _payBill(List<BillModel> bills, BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black54,
          body: SafeArea(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                // fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 15.0,
                    ),
                    padding: EdgeInsets.only(
                      top: 40.0,
                      bottom: 10.0,
                      left: 15.0,
                      right: 15.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: _isPaying,
                      builder: (context, val, child) {
                        if (val) {
                          return FutureBuilder(
                            future: _processPayment(),
                            builder: (context, AsyncSnapshot<bool> res) {
                              if (res.hasError) {
                                Future.delayed(Duration(seconds: 5), () {
                                  _isPaying.value = false;
                                  Navigator.of(context).pop();
                                });
                                return Container(
                                  height: 500,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/img/empty_state.png',
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (res.hasData) {
                                Future.delayed(Duration(seconds: 5), () {
                                  _isPaying.value = false;
                                  Navigator.of(context).pop();
                                });
                                return Container(
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          child: Image.asset(
                                            'assets/img/successful_payment.png',
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        Text("You payment has been confirmed")
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Container(
                                          child: AppSpinner(),
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Text("You payment is being proccessed")
                                      ],
                                    ),
                                  ),
                                );
                              }
                            },
                          );
                        }
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                height: 2,
                                color: shedAppBlue400,
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Column(
                                children: bills.map((bill) {
                                  return Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(
                                          "${bill.utility.name} Bill, ${DateFormat.yMMMM().format(bill.period)}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline
                                              .copyWith(fontSize: 15),
                                        ),
                                      ),
                                      Text(
                                        formatter.format(bill.utility.cost),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline
                                            .copyWith(fontSize: 13),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              SizedBox(
                                height: 10.0,
                              ),
                              Container(
                                height: 2,
                                color: shedAppBlue400,
                              ),
                              Padding(
                                padding: EdgeInsets.all(5.0),
                                child: Text(
                                  "TOTAL  ${formatter.format(
                                    bills
                                        .map((it) => it.utility.cost)
                                        .toList()
                                        .reduce((prev, nxt) => prev + nxt),
                                  )}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(
                                        fontSize: 20,
                                        // color: Colors.white,
                                      ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Container(
                                height: 2,
                                color: shedAppBlue400,
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              RaisedButton(
                                onPressed: () => _processPayment(),
                                child: Text("PAY"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: .5,
                    child: FloatingActionButton(
                      heroTag: "cls",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
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
  }

  /// page widget that displays notification for outstanding bills,
  /// displays a list of bills and a button that pops up the 
  /// pay outstanding bills window
  @override
  Widget build(BuildContext context) {
    formatter = NumberFormat.currency(
      name: "NGN",
      symbol: "NGN ", //
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    );
    return AppScaffold(
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
                color: shedAppErrorRed,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.headline.copyWith(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                  children: [
                    TextSpan(
                      text: "You have ",
                    ),
                    TextSpan(
                      text: formatter.format(3900),
                      style: TextStyle(
                        color: shedAppYellow100,
                      ),
                    ),
                    TextSpan(
                      text: " in outstanding bills",
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Expanded(
              child: FutureBuilder(
                future: getBills(),
                builder: (context, AsyncSnapshot<List<BillModel>> res) {
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
                      );
                    }
                    _bills = res.data;
                    return ListView.separated(
                      itemCount: res.data.length,
                      itemBuilder: (context, idx) {
                        final BillModel bill = res.data[idx];
                        return Card(
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 15.0,
                              // horizontal: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "${bill.utility.name} Bill, ${DateFormat.yMMMM().format(bill.period)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline
                                            .copyWith(fontSize: 15),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  formatter.format(bill.utility.cost),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 6.0,
                                ),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        "Payment due on ${DateFormat.yMMMMEEEEd().format(bill.dueDate)}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .body1,
                                      ),
                                    ),
                                    RaisedButton(
                                      padding: EdgeInsets.all(5),
                                      onPressed: () =>
                                          _payBill([bill], context),
                                      child: Text("Pay"), //each outstanding bill payment button
                                    )
                                  ],
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
      pageTitle: ValueNotifier("OUTSTANDING BILLS"),  //page title
      /*bottomWidget: Container( //bottom widget for paying oustanding bills button
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          bottom: 10.0,
        ),
        color: Colors.white.withOpacity(0.1),
        child: RaisedButton(
          onPressed: () => _payBill(_bills, context),
          child: Text("Pay Outstanding Bills"),
        ),
      ),*/
    );
  }
}
