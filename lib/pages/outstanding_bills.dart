import 'dart:convert';
import 'package:badges/badges.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/components/auth_button_spinner.dart';
import 'package:facil_tenant/models/balance_model.dart';
import 'package:facil_tenant/models/outstanding_bills_model.dart';
import 'package:facil_tenant/models/payment_type_model.dart';
import 'package:facil_tenant/models/payments_model.dart';
import 'package:facil_tenant/pages/webview_page.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
import '../components/app_scaffold.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:crypto/crypto.dart' as crypto;

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
  final _httpService = HttpService();
  bool _proceedToPayButton = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final String fixedPayment = '1';
  final String partialPayment = '1';
  final String fullPayment = '2';
  final String balancePayment = '3'; //paying off a balance
  final String hideTextField =
      '4'; //means partial payment is selected and field is closed

  final choicePeriod = ValueNotifier({"year": (DateTime.now()).year});
  String yearToSearch = ((DateTime.now()).year).toString();
  String monthToSearch = "0";
  String monthName = "All";

  Map<String, String> selectedChipValues =
      {}; //selected chip values holds the uniqueKey of the payment type and has it's value a fullPayment/partialPayment
  Map<String, TextEditingController> partialFeesControllers =
      {}; //holds each controller for each selected field especially partialPayments

  Map<String, PaymentsModel> selectedBills = {};
  Map<String, double> selectedBillsAmountClone = {};

  Map<String, String> monthsMap = {
    "All": "0",
    "January": "1",
    "February": "2",
    "March": "3",
    "April": "4",
    "May": "5",
    "June": "6",
    "July": "7",
    "August": "8",
    "September": "9",
    "October": "10",
    "November": "11",
    "December": "12"
  };
  static String _getYearsRange() {
    int _startPoint = 2018;
    int _endPoint = DateTime.now().year;
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

  Future<Map<String, dynamic>> _fetchTransactionKey() async {
    List<Map<String, dynamic>> requestData = [];
    for (var i in selectedBills.values) {
      // add balance id later on when balances are in
      Map<String, dynamic> eachData = i.balanceId == null
          ? {
              "year": i.year,
              "month": i.month,
              "unit_amount": i.paymentType.amount,
              "payment_type_id": i.paymentType.id,
              "due_type_id": i.dueTypeId
            }
          : {
              "year": i.year,
              "month": i.month,
              "unit_amount": i.paymentType.amount,
              "payment_type_id": i.paymentType.id,
              "due_type_id": i.dueTypeId,
              "balance_id": i.balanceId
            };
      requestData.add(eachData);
    }
    Map<String, dynamic> _response =
        await _httpService.getTransactionId(requestData);
    return Future.value(_response);
  }

  List<PaymentTypeModel> sortYearlyDues(dynamic yearlyDues) {
    List<PaymentTypeModel> _yearly = [];
    for (var y = 0; y < yearlyDues.length; y++) {
      Map<String, dynamic> _eachYearlyBill = yearlyDues[y];
      var bytes =
          utf8.encode("${_eachYearlyBill['name']}${_eachYearlyBill["id"]}");
      String uniqueKey = crypto.sha1.convert(bytes).toString();
      _yearly.add(PaymentTypeModel(
          uniqueKey: uniqueKey,
          id: _eachYearlyBill["id"],
          name: _eachYearlyBill["name"],
          amount: _eachYearlyBill["amount"],
          fixedPayment: _eachYearlyBill["fixed_payment"],
          paymentUnit: _eachYearlyBill["payment_unit"]));
    }
    return _yearly;
  }

  List<BalanceModel> sortBalances(List<Map<String, dynamic>> balances) {
    List<BalanceModel> b = [];
    balances.forEach((data) {
      Map<String, dynamic> paymentType = data['paymentType'];
      List<Map<String, dynamic>> paymentInfo = List<Map<String, dynamic>>.from(
          json.decode(data['transaction']['payment_info']));
      Map<String, dynamic> transaction;
      paymentInfo.forEach((d) {
        if (d['payment_balance_id'].toString() == data['id']) {
          transaction = d;
        }
      });
      var bytes = utf8.encode("${data['id']}${paymentType['name']}");
      String uniqueKey = crypto.sha1.convert(bytes).toString();
      PaymentTypeModel pt = PaymentTypeModel(
          uniqueKey: uniqueKey,
          id: paymentType['id'],
          name: paymentType['name'],
          amount: paymentType['amount'],
          paymentUnit: paymentType['payment_unit']);
      b.add(BalanceModel(
          id: data['id'],
          balance: data['balance'],
          year: transaction['year'],
          month: transaction['month'],
          paymentType: pt));
    });
    return b;
  }

  List<OutstandingBillsModel> sortMonthlyDues(dynamic monthlyDues) {
    List<OutstandingBillsModel> _monthly = [];
    for (var m = 0; m < monthlyDues.length; m++) {
      List<PaymentTypeModel> _paymentTypesList = [];
      Map<String, dynamic> _eachBill = monthlyDues[m];
      for (var j = 0; j < _eachBill["data"].length; j++) {
        Map<String, dynamic> _eachType = _eachBill["data"][j];
        var bytes = utf8.encode("${_eachType['name']}${_eachBill['name']}");
        String uniqueKey = crypto.sha1.convert(bytes).toString();
        _paymentTypesList.add(PaymentTypeModel(
            uniqueKey: uniqueKey,
            id: _eachType["id"],
            name: _eachType["name"],
            amount: _eachType["amount"],
            fixedPayment: _eachType["fixed_payment"],
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

  Future<Map<String, List>> getUserOutstandingBills(
      String year, String month) async {
    Map<String, dynamic> _response = (month == "0")
        ? await _httpService.fetchOutstandingBills(year: year)
        : await _httpService.fetchOutstandingBills(year: year, month: month);
    Map<String, dynamic> _res = await _httpService.fetchBalances();

    if (!_res['status']) throw new Exception(_res["message"]);
    if (_response["status"] == false) throw new Exception(_response["message"]);

    Map<String, List> _outstanding = {};
    Map<String, dynamic> _content = _response["data"];
    List<Map<String, dynamic>> _balances =
        List<Map<String, dynamic>>.from(_res['data']);
    List<BalanceModel> _balanceList = sortBalances(_balances);
    List<PaymentTypeModel> _yearly = sortYearlyDues(_content["yearly"]);
    List<OutstandingBillsModel> _monthly = sortMonthlyDues(_content["monthly"]);

    _outstanding = {
      "monthly": _monthly,
      "yearly": _yearly,
      "balances": _balanceList
    };
    return Future.value(_outstanding);
  }

  _payBill(Map<String, PaymentsModel> bills, BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (BuildContext ctx, setState) {
          return Scaffold(
            key: _scaffoldKey,
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
                        child: SingleChildScrollView(
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
                              for (var bill in bills.values)
                                Column(children: [
                                  Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
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
                                          "${double.parse(bill.paymentType.amount)}0",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline
                                              .copyWith(fontSize: 15),
                                        ),
                                        SizedBox(
                                          width: 4.0,
                                        ),
                                        bill.paymentType.fixedPayment !=
                                                fixedPayment
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                    (bill.balanceId != null)
                                                        ? ChoiceChip(
                                                            label:
                                                                Text("Balance"),
                                                            selected: (selectedChipValues[bill
                                                                    .paymentType
                                                                    .uniqueKey] ==
                                                                balancePayment),
                                                            onSelected: (bool
                                                                newValue) {
                                                              setState(() {
                                                                selectedChipValues[bill
                                                                        .paymentType
                                                                        .uniqueKey] =
                                                                    balancePayment;
                                                                bill.paymentType
                                                                    .amount = selectedBillsAmountClone[bill
                                                                        .paymentType
                                                                        .uniqueKey]
                                                                    .toString();
                                                                bill.dueTypeId =
                                                                    balancePayment;
                                                              });
                                                            },
                                                          )
                                                        : ChoiceChip(
                                                            label: Text("Full"),
                                                            selected: (selectedChipValues[bill
                                                                    .paymentType
                                                                    .uniqueKey] ==
                                                                fullPayment),
                                                            onSelected: (bool
                                                                newValue) {
                                                              setState(() {
                                                                selectedChipValues[bill
                                                                        .paymentType
                                                                        .uniqueKey] =
                                                                    fullPayment;
                                                                bill.paymentType
                                                                    .amount = selectedBillsAmountClone[bill
                                                                        .paymentType
                                                                        .uniqueKey]
                                                                    .toString();
                                                                bill.dueTypeId =
                                                                    fullPayment;
                                                              });
                                                            },
                                                          ),
                                                    ChoiceChip(
                                                      label: Text("Partial"),
                                                      selected: (selectedChipValues[bill
                                                                  .paymentType
                                                                  .uniqueKey] ==
                                                              partialPayment ||
                                                          selectedChipValues[bill
                                                                  .paymentType
                                                                  .uniqueKey] ==
                                                              hideTextField),
                                                      onSelected:
                                                          (bool newValue) {
                                                        setState(() {
                                                          selectedChipValues[bill
                                                                  .paymentType
                                                                  .uniqueKey] =
                                                              partialPayment;
                                                        });
                                                      },
                                                    ),
                                                  ])
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                    ChoiceChip(
                                                        label: Text("Full"),
                                                        selected: true),
                                                    ChoiceChip(
                                                        label: Text("Partial",
                                                            style: TextStyle(
                                                                decoration:
                                                                    TextDecoration
                                                                        .lineThrough)),
                                                        selected: false),
                                                  ]),
                                      ]),
                                  (selectedChipValues[
                                              bill.paymentType.uniqueKey] ==
                                          partialPayment)
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                                child: TextFormField(
                                              controller:
                                                  partialFeesControllers[bill
                                                      .paymentType.uniqueKey],
                                              decoration: InputDecoration(
                                                border: null,
                                                hintText: "Enter value",
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              autocorrect: false,
                                            )),
                                            Container(
                                                alignment: Alignment.center,
                                                width: 60.0,
                                                child: FlatButton(
                                                  onPressed: () {
                                                    try {
                                                      String key = bill
                                                          .paymentType
                                                          .uniqueKey;
                                                      double actualAmount =
                                                          selectedBillsAmountClone[
                                                              key];
                                                      double _fieldValue =
                                                          double.parse(
                                                              partialFeesControllers[
                                                                      key]
                                                                  .text);
                                                      if (_fieldValue < 1) {
                                                        renderSnackBar(
                                                            "Value cannot be less than 1");
                                                        return;
                                                      }
                                                      if (_fieldValue >
                                                          actualAmount) {
                                                        renderSnackBar(
                                                            'Value cannot be greater than ${formatter.format(actualAmount)}');
                                                        return;
                                                      }
                                                      setState(() {
                                                        bill.paymentType
                                                                .amount =
                                                            _fieldValue
                                                                .toString();
                                                        selectedChipValues[
                                                                key] =
                                                            hideTextField;
                                                        bill.dueTypeId =
                                                            partialPayment;
                                                      });
                                                    } catch (e) {
                                                      renderSnackBar(
                                                          "Value should contain numbers only");
                                                      return;
                                                    }
                                                  },
                                                  child: Text("Ok"),
                                                ))
                                          ],
                                        )
                                      : SizedBox()
                                ]),
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
                                              ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      Text(
                                        "${formatter.format(
                                          bills.values
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
                                height: 10.0,
                              ),
                              RaisedButton(
                                onPressed: () async {
                                  //due_type_id should be 2 once the amount matches the original amount
                                  setState(() {
                                    _proceedToPayButton = true;
                                  });
                                  Map<String, dynamic> _response =
                                      await _fetchTransactionKey();
                                  setState(() {
                                    _proceedToPayButton = false;
                                  });
                                  if (!_response['status']) {
                                    renderSnackBar(_response['message']);
                                    return;
                                  }
                                  String url = _response['data'];
                                  await FacilWebView(url).openWebView();
                                },
                                child: _proceedToPayButton
                                    ? AuthButtonSpinner(Colors.white)
                                    : Text("Proceed"),
                              )
                            ],
                          ),
                        )),
                    Positioned(
                      top: 0,
                      right: .5,
                      child: FloatingActionButton(
                        heroTag: "cls",
                        onPressed: () {
                          selectedBillsAmountClone.forEach((k, v) {
                            if (selectedBills[k] != null) {
                              selectedBills[k].paymentType.amount =
                                  v.toString();
                              selectedBills[k].dueTypeId =
                                  (selectedBills[k].balanceId == null)
                                      ? fullPayment
                                      : balancePayment;
                            }
                          });
                          _proceedToPayButton = false;
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

  renderSnackBar(String text) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    ));
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
      floatingActionButton: (selectedBills.length < 1)
          ? Container(
              margin: EdgeInsets.only(left: 30.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FloatingActionButton(
                    heroTag: "filterHistory",
                    onPressed: () {
                      Picker(
                          adapter: PickerDataAdapter<String>(
                              pickerdata:
                                  new JsonDecoder().convert(pickerData2),
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
              ))
          : Container(
              margin: EdgeInsets.only(left: 30.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: RaisedButton(
                    padding: EdgeInsets.all(5),
                    onPressed: () {
                      selectedBills.forEach((k, v) {
                        selectedChipValues[k] = (v.balanceId == null)
                            ? fullPayment
                            : balancePayment;
                        partialFeesControllers[k] = TextEditingController(
                            text: selectedBills[k].paymentType.amount);
                        selectedBillsAmountClone[k] =
                            double.parse(selectedBills[k].paymentType.amount);
                      });
                      _payBill(selectedBills, context);
                    },
                    child: Text("Pay",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
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
                child: Container(
              margin: EdgeInsets.only(bottom: 20.0),
              child: FutureBuilder(
                future: getUserOutstandingBills(yearToSearch, monthToSearch),
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
                              res.error.toString(),
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
                    List<BalanceModel> _balances = res.data["balances"];
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
                                        fontSize: 16,
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
                                                .copyWith(fontSize: 20),
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
                                        ChoiceChip(
                                          label: selectedBills
                                                  .containsKey(_yd.uniqueKey)
                                              ? Text("Selected")
                                              : Text("Select"),
                                          selected: (selectedBills
                                              .containsKey(_yd.uniqueKey)),
                                          onSelected: (bool newValue) {
                                            if (!selectedBills
                                                .containsKey(_yd.uniqueKey)) {
                                              PaymentsModel _toPay =
                                                  PaymentsModel(
                                                      id: _yd.id,
                                                      year: yearToSearch,
                                                      month: ((DateTime.now())
                                                              .month)
                                                          .toString(),
                                                      dueTypeId: fullPayment,
                                                      paymentType: _yd);
                                              setState(() {
                                                selectedBills[_yd.uniqueKey] =
                                                    _toPay;
                                              });
                                            } else {
                                              setState(() {
                                                selectedBills
                                                    .remove(_yd.uniqueKey);
                                              });
                                            }
                                          },
                                        ),
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
                                      fontSize: 16,
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
                                    monthToSearch != "0"
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
                                                                fontSize: 20),
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
                                                    ChoiceChip(
                                                      label: selectedBills
                                                              .containsKey(
                                                                  _mdPaymentType
                                                                      .uniqueKey)
                                                          ? Text("Selected")
                                                          : Text("Select"),
                                                      selected: (selectedBills
                                                          .containsKey(
                                                              _mdPaymentType
                                                                  .uniqueKey)),
                                                      onSelected:
                                                          (bool newValue) {
                                                        if (!selectedBills
                                                            .containsKey(
                                                                _mdPaymentType
                                                                    .uniqueKey)) {
                                                          PaymentsModel _toPay = PaymentsModel(
                                                              id: _mdPaymentType
                                                                  .id,
                                                              year:
                                                                  yearToSearch,
                                                              month: monthsMap[_md
                                                                  .monthName],
                                                              dueTypeId:
                                                                  fullPayment,
                                                              paymentType:
                                                                  _mdPaymentType);
                                                          setState(() {
                                                            selectedBills[
                                                                    _mdPaymentType
                                                                        .uniqueKey] =
                                                                _toPay;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            selectedBills.remove(
                                                                _mdPaymentType
                                                                    .uniqueKey);
                                                          });
                                                        }
                                                      },
                                                    ),
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
                        SizedBox(
                          height: 30.0,
                        ),
                        _balances.length > 0
                            ? RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(
                                        fontSize: 16,
                                        color: shedAppBlue400,
                                      ),
                                  children: [
                                    TextSpan(
                                      text: "Balances",
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(),
                        /**Render balances below */
                        ListView.separated(
                          itemCount: _balances.length,
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemBuilder: (context, idx) {
                            final _b = _balances[idx];
                            PaymentTypeModel _bPaymentType = _b.paymentType;
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
                                    Align(
                                      child: Padding(
                                        child: Badge(
                                          shape: BadgeShape.square,
                                          borderRadius: 20,
                                          toAnimate: true,
                                          badgeColor: shedAppBlue50,
                                          badgeContent: Text(
                                            "${Months[int.parse(_b.month) - 1]}, ${_b.year}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(fontSize: 15),
                                          ),
                                        ),
                                        padding: EdgeInsets.only(right: 20.0),
                                      ),
                                      alignment: Alignment.topLeft,
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Text(
                                            "${_bPaymentType.name}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(fontSize: 20),
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
                                            "${formatter.format(double.parse(_b.balance))}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline
                                                .copyWith(fontSize: 20),
                                          ),
                                        ),
                                        ChoiceChip(
                                          label: selectedBills.containsKey(
                                                  _b.paymentType.uniqueKey)
                                              ? Text("Selected")
                                              : Text("Select"),
                                          selected: (selectedBills.containsKey(
                                              _b.paymentType.uniqueKey)),
                                          onSelected: (bool newValue) {
                                            if (!selectedBills.containsKey(
                                                _b.paymentType.uniqueKey)) {
                                              _b.paymentType.amount =
                                                  _b.balance;
                                              PaymentsModel _toPay =
                                                  PaymentsModel(
                                                      id: _b.paymentType.id,
                                                      year: _b.year,
                                                      balanceId: _b.id,
                                                      month: _b.month,
                                                      dueTypeId: balancePayment,
                                                      paymentType:
                                                          _bPaymentType);
                                              setState(() {
                                                selectedBills[_bPaymentType
                                                    .uniqueKey] = _toPay;
                                              });
                                            } else {
                                              setState(() {
                                                selectedBills.remove(
                                                    _bPaymentType.uniqueKey);
                                              });
                                            }
                                          },
                                        ),
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
                      ],
                    );
                  } else {
                    return AppSpinner();
                  }
                },
              ),
            )),
          ],
        ),
      ),
      pageTitle: ValueNotifier("OUTSTANDING BILLS"),
    );
  }
}
