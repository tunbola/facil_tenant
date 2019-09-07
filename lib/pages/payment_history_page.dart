import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/mock/mock_payments.dart';
import 'package:facil_tenant/models/bill_model.dart';
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

class PaymentHistoryPage extends StatelessWidget {
  final choicePeriod = ValueNotifier({"year": 2019, "month": 6});
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
                                      lastDate: DateTime(DateTime.now().year),
                                      firstDate: DateTime(2018),
                                      onChanged: (valu) =>
                                          choicePeriod.value = {
                                            "year": valu.year,
                                            "month": val["month"]
                                          },
                                    ),
                                  ),
                                  Text(
                                    "Select Month",
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    child: Wrap(
                                        alignment: WrapAlignment.center,
                                        children: Months.map((it) {
                                          return GestureDetector(
                                            child: Card(
                                              color: val["month"] ==
                                                      Months.indexOf(it)
                                                  ? shedAppBlue50
                                                  : shedAppYellow50,
                                              child: Padding(
                                                padding: EdgeInsets.all(10.0),
                                                child: Text(
                                                  it,
                                                  style: TextStyle(
                                                    color: val["month"] ==
                                                            Months.indexOf(it)
                                                        ? Colors.white
                                                        : shedAppBodyBlack,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            onTap: () => choicePeriod.value = {
                                                  "year": val["year"],
                                                  "month": Months.indexOf(it)
                                                },
                                          );
                                        }).toList().cast<Widget>()),
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
                                            print(val);
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
                "Showing Bill Payments for July 2019",
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
                    return ListView.separated(
                      itemCount: res.data.length,
                      itemBuilder: (context, idx) {
                        final BillModel bill = res.data[idx];
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
                                        "${bill.utility.name} Bill",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline
                                            .copyWith(fontSize: 25),
                                      ),
                                    ),
                                    Text(
                                      "FAC-BILL::00${idx + 1}",
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption,
                                    ),
                                  ],
                                ),
                                Text(
                                  "${DateFormat.yMMMM().format(bill.period)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1,
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  formatter.format(bill.utility.cost),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(fontSize: 50),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  "Paid: ${DateFormat.yMMMMEEEEd().format(bill.dueDate)}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1,
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
