import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/components/auth_button_spinner.dart';
import 'package:facil_tenant/models/outstanding_bills_model.dart';
import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:facil_tenant/models/payments_model.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/services/navigation_service.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
import '../components/app_scaffold.dart';
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;
import 'package:flutter_picker/flutter_picker.dart';

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

class OutstandingBillsPage extends StatefulWidget {
  @override
  _OutstandingBillsPageState createState() => _OutstandingBillsPageState();
}

class _OutstandingBillsPageState extends State<OutstandingBillsPage> {
  final ValueNotifier _isPaying = ValueNotifier(false);
  final _httpService = HttpService();
  bool _proceedToPayButton = false;

  final choicePeriod = ValueNotifier({"year": (DateTime.now()).year});
  String errMsg = "";
  //double totalDebt = 0.00;
  static NavigationService _navigationService = locator<NavigationService>();
  String yearToSearch = ((DateTime.now()).year).toString();
  String monthToSearch = "00";
  String monthName = "All";

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
    ${_OutstandingBillsPageState._getYearsRange()},
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

  Future<bool> _processPayment() async {
    _isPaying.value = true;
    await Future.delayed(
      Duration(seconds: 3),
    );
    return Future.value(true);
  }

  Future<Map<String, dynamic>> _fetchTransactionKey(
      String month, String year, String paymentTypeId) async {
    Map<String, dynamic> _response =
        await _httpService.getTransactionId(month, year, paymentTypeId);
    return Future.value(_response);
  }

  List<PaymentTypeModel> sortYearlyDues(dynamic yearlyDues) {
    List<PaymentTypeModel> _yearly = [];
    for (var y = 0; y < yearlyDues.length; y++) {
      Map<String, dynamic> _eachYearlyBill = yearlyDues[y];
      _yearly.add(PaymentTypeModel(
          id: _eachYearlyBill["id"],
          name: _eachYearlyBill["name"],
          amount: _eachYearlyBill["amount"],
          convenienceFee: _eachYearlyBill["convenience_fee"],
          paymentUnit: _eachYearlyBill["payment_unit"]));
    }
    return _yearly;
  }

  List<OutstandingBillsModel> sortMonthlyDues(dynamic monthlyDues) {
    List<OutstandingBillsModel> _monthly = [];
    for (var m = 0; m < monthlyDues.length; m++) {
      List<PaymentTypeModel> _paymentTypesList = [];
      Map<String, dynamic> _eachBill = monthlyDues[m];
      for (var j = 0; j < _eachBill["data"].length; j++) {
        Map<String, dynamic> _eachType = _eachBill["data"][j];
        _paymentTypesList.add(PaymentTypeModel(
            id: _eachType["id"],
            name: _eachType["name"],
            amount: _eachType["amount"],
            convenienceFee: _eachType["convenience_fee"],
            paymentUnit: _eachType["payment_unit"]));
      }
      _monthly.add(OutstandingBillsModel(
        id: _eachBill["id"].toString(),
        monthName: _eachBill["name"],
        paymentTypes: _paymentTypesList,
      ));
    }
    return _monthly;
  }

  Future<Map<String, List>> _fetchOutstandingBills(
      String year, String month) async {
    Map<String, dynamic> _response = month == "00"
        ? await _httpService.fetchOutstandingBills(year: year)
        : await _httpService.fetchOutstandingBills(year: year, month: month);
    if (_response["status"] == false) errMsg = _response["message"];
    Map<String, List> _outstanding = {};
    Map<String, dynamic> _content = _response["data"];
    List<PaymentTypeModel> _yearly = sortYearlyDues(_content["yearly"]);
    List<OutstandingBillsModel> _monthly = sortMonthlyDues(_content["monthly"]);

    _outstanding = {"monthly": _monthly, "yearly": _yearly};
    return Future.value(_outstanding);
  }

  _payBill(List<PaymentsModel> bills, BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext ctx, setState) {
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
                                          Text(
                                              "You payment is being proccessed")
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
                                            "${bill.paymentType.name}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(fontSize: 15),
                                          ),
                                        ),
                                        Text(
                                          formatter.format(double.parse(
                                              bill.paymentType.amount)),
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
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "TOTAL",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(
                                                  fontSize: 20,
                                                  // color: Colors.white,
                                                ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        Text(
                                          "${formatter.format(
                                            bills
                                                .map((it) => double.parse(
                                                    it.paymentType.amount))
                                                .toList()
                                                .reduce(
                                                    (prev, nxt) => prev + nxt),
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
                                      ],
                                    )),
                                Container(
                                  height: 2,
                                  color: shedAppBlue400,
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                RaisedButton(
                                  onPressed: () async {
                                    setState(() {
                                      _proceedToPayButton = true;
                                    });
                                    PaymentsModel _bill = bills[0];
                                    Map<String, dynamic> _response =  await _fetchTransactionKey(
                                        _bill.month, _bill.year, _bill.id);
                                    setState(() {
                                      _proceedToPayButton = false;
                                    });
                                    if (!_response['status']) {
                                      Scaffold.of(context).showSnackBar(SnackBar(content: Text(_response['message']), backgroundColor: Colors.red,));
                                      return;
                                    }
                                    _navigationService
                                      .navigateTo(routes.Paystack, arg: _response['data']);
                                  },
                                  child: _proceedToPayButton
                                      ? AuthButtonSpinner(Colors.white)
                                      : Text("Proceed"),
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
        });
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
      floatingActionButton: Container(
          margin: EdgeInsets.only(left: 30.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
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
                          monthName = values[1];
                        });
                      }).showDialog(context);
                },
                child: Icon(
                  Icons.calendar_today,
                )),
          )),
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
                        fontSize: 13,
                        color: Colors.white,
                      ),
                  children: [
                    TextSpan(
                      text: "Your outstanding bills for $yearToSearch",
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
                future: _fetchOutstandingBills(yearToSearch, monthToSearch),
                builder: (context, res) {
                  if (res.hasError) {
                    return Container(
                        height: MediaQuery.of(context).size.height,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/img/empty_state.png'),
                          ),
                        ),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 100.0),
                          child: Center(
                            child: Text(
                              errMsg,
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ));
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
                          child: Container(
                            margin: EdgeInsets.only(bottom: 100.0),
                            child: Center(
                              child: Text(
                                "Empty",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ));
                    }
                    List<OutstandingBillsModel> _monthlyDues =
                        res.data["monthly"];
                    List<PaymentTypeModel> _yearlyDues = res.data["yearly"];
                    return ListView(
                      children: <Widget>[
                        _yearlyDues.length > 0
                            ? RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(
                                        fontSize: 14,
                                        color: shedAppBlue400,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: "Yearly dues",
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        /**List view for rendering yearly dues */
                        ListView.separated(
                          itemCount: _yearlyDues.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, idx) {
                            final _yd = _yearlyDues[idx];
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
                                            "${_yd.name}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(fontSize: 22),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5.0,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            formatter.format(
                                                double.parse(_yd.amount)),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(fontSize: 20),
                                          ),
                                        ),
                                        RaisedButton(
                                          padding: EdgeInsets.all(5),
                                          onPressed: () {
                                            PaymentsModel _toPay =
                                                PaymentsModel(
                                                    id: _yd.id,
                                                    year: yearToSearch,
                                                    month:
                                                        ((DateTime.now()).month)
                                                            .toString(),
                                                    paymentType: _yd);
                                            _payBill([_toPay], context);
                                          },
                                          child: Text(
                                              "Pay"), //each outstanding bill payment button
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 1.0,
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
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style:
                                Theme.of(context).textTheme.headline.copyWith(
                                      fontSize: 14,
                                      color: shedAppBlue400,
                                    ),
                            children: [
                              TextSpan(
                                text: "Monthly dues",
                              ),
                            ],
                          ),
                        ),
                        /**Render monthly dues below */
                        ListView.separated(
                          itemCount: _monthlyDues.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, sn) {
                            final _md = _monthlyDues[sn];
                            return _md.paymentTypes.length < 1 &&
                                    monthToSearch != "00"
                                ? RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline
                                          .copyWith(
                                            fontSize: 12,
                                            color: Colors.red,
                                          ),
                                      children: [
                                        TextSpan(
                                          text:
                                              "No monthly outstanding payment found for ${_md.monthName}",
                                        ),
                                      ],
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: ListView.builder(
                                      itemCount: _md.paymentTypes.length,
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      itemBuilder: (context, idx) {
                                        PaymentTypeModel _mdPaymentType =
                                            _md.paymentTypes[idx];
                                        return Card(
                                          elevation: 0,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 15.0,
                                              // horizontal: 10.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                idx == 0
                                                    ? Align(
                                                        child: Padding(
                                                          child: Badge(
                                                            shape: BadgeShape
                                                                .square,
                                                            borderRadius: 20,
                                                            toAnimate: true,
                                                            badgeColor:
                                                                shedAppBlue50,
                                                            badgeContent: Text(
                                                              "${_md.monthName}",
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .headline
                                                                  .copyWith(
                                                                      fontSize:
                                                                          15),
                                                            ),
                                                          ),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 20.0),
                                                        ),
                                                        alignment:
                                                            Alignment.topLeft,
                                                      )
                                                    : SizedBox(),
                                                SizedBox(
                                                  height: 20.0,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        "${_mdPaymentType.name}",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline
                                                            .copyWith(
                                                                fontSize: 22),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        formatter.format(
                                                            double.parse(
                                                                _mdPaymentType
                                                                    .amount)),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline
                                                            .copyWith(
                                                                fontSize: 20),
                                                      ),
                                                    ),
                                                    RaisedButton(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      onPressed: () {
                                                        PaymentsModel _toPay =
                                                            PaymentsModel(
                                                                id:
                                                                    _mdPaymentType
                                                                        .id,
                                                                year:
                                                                    yearToSearch,
                                                                month: monthsMap[_md
                                                                    .monthName],
                                                                paymentType:
                                                                    _mdPaymentType);
                                                        _payBill(
                                                            [_toPay], context);
                                                      },
                                                      child: Text(
                                                          "Pay"), //each monthly outstanding bill payment button
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 1.0,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                          },
                          separatorBuilder: (context, idx) => Container(
                            height: _monthlyDues[idx].paymentTypes.length < 1
                                ? 0.0
                                : 0.5,
                            color: Colors.grey,
                          ),
                        ),
                      ],
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
      pageTitle: ValueNotifier("OUTSTANDING BILLS"), //page title
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
