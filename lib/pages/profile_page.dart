import 'dart:convert';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/dependents_model.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import "package:facil_tenant/services/http_service.dart";
import 'package:facil_tenant/models/index.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import "package:facil_tenant/components/auth_button_spinner.dart";

NumberFormat formatter;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  ValueNotifier<int> _activePage = ValueNotifier(0);
  TextEditingController _start = TextEditingController(text: "");
  TextEditingController _gender = TextEditingController(text: "");
  TextEditingController _relation = TextEditingController(text: "");
  ValueNotifier _picture = ValueNotifier(null);
  TabController _ctrlr;

  final _formKey = GlobalKey<FormState>();

  final _email = TextEditingController();
  final _surname = TextEditingController();
  final _othernames = TextEditingController();
  final _phone = TextEditingController();
  final _visitDate = TextEditingController();
  final _address = TextEditingController();
  String _title = "Mr";
  var userRoleId;
  ValueNotifier _dependent = ValueNotifier(null);

  HttpService _httpService = new HttpService();
  AccessService accessService = AccessService();

  bool _buttonClicked = false;
  Map<String, dynamic> _report = {"status": false, "message": ""};

  Map<String, dynamic> outStanding = {
    "status": false,
    "message": "",
    "data": {}
  };
  Map<String, dynamic> paymentInfo = {
    "status": false,
    "message": "",
    "data": {}
  };
  Map<String, dynamic> requestsInfo = {
    "status": false,
    "message": "",
    "data": {"total": 0, "completed": 0, "pending": 0, "failed": 0}
  };
  Map<String, dynamic> dependentsInfo = {
    "status": false,
    "message": "",
    "data": []
  };

  Future<UserProfileModel> _getUserProfile() async {
    String userId = await this.accessService.getUserId();
    this.userRoleId = await this.accessService.userRole();
    Map<String, dynamic> response = await _httpService.fetchProfile(userId);
    Map<String, dynamic> profile = response["data"];
    UserProfileModel userProfile = UserProfileModel(
      user: UserModel.fromJson(profile),
      visits: (profile["propertyAccesses"] as List)
          .map((data) => VisitModel.fromJson(data))
          .toList(),
      property: PropertyModel.fromJson(profile["property"]),
      childrenUser: (profile["childUsers"] as List)
          .map((data) => UserModel.fromJson(data))
          .toList(),
      parentUser: UserModel.fromJson(profile["parentUser"]),
    );
    return Future.value(userProfile);
  }

  Future<Map<String, dynamic>> sortProfileFormData(
      String email,
      String surname,
      String othernames,
      String phone,
      String visitDate,
      String address,
      String title,
      String dependent,
      String pageType) async {
    if (pageType == "visits") {
      //call method to add property access
      return await createVisit(surname, othernames, phone, visitDate);
    }

    if (pageType == "dependents") {
      if (AccessService.isPhoneNumber(phone)) {
        return await _httpService.createDependentUser(phone, dependent);
      }
      return {"status": false, "message": "Phone number is invalid"};
    }
    //update profile
    return await updateUserProfile(
        surname, othernames, phone, email, address, title);
  }

  //update profile
  Future<Map<String, dynamic>> updateUserProfile(
      String surname,
      String othernames,
      String phone,
      String email,
      String address,
      String title) async {
    if (surname.length < 1 ||
        othernames.length < 1 ||
        phone.length < 1 ||
        email.length < 1 ||
        title.length < 1 ||
        address.length < 1)
      return {"status": false, "message": "All fields are required ..."};
    if (!AccessService.isPhoneNumber(phone))
      return {
        "status": false,
        "message": "Phone number should contain 11 numbers"
      };
    if (!AccessService.isValidEmail(email))
      return {"status": false, "message": "Email address is invalid"};
    return await _httpService.updateProfile(
        surname, othernames, phone, email, address, title);
  }

  Future<List<dynamic>> fetchDependents() async {
    Map<String, dynamic> response = await _httpService.fetchDependents();
    if (!response['status']) return Future.value(null);
    List<dynamic> res =
        response['data'].map((c) => DependentsModel.fromJson(c)).toList();
    return Future.value(res);
  }

  Future<Map<String, dynamic>> createVisit(
      String surname, String othernames, String phone, String visitDate) async {
    if (surname.length < 1 ||
        othernames.length < 1 ||
        phone.length < 1 ||
        visitDate.length < 1)
      return {"status": false, "message": "All fields are required ..."};

    if (!AccessService.isPhoneNumber(phone))
      return {"status": false, "message": "Phone should contain 11 numbers"};
    var now = DateTime.now();
    DateTime chosenDate = DateTime.parse(visitDate);
    if (chosenDate.isBefore(now))
      return {
        "status": false,
        "message": "You cannot choose the date before today's"
      };
    return await _httpService.registerVisit(
        "$surname $othernames", phone, visitDate);
  }

  //get user's outstanding bills information
  Future<Map<String, dynamic>> getTotalOustanding() async {
    String year = (DateTime.now().year).toString();
    Map<String, dynamic> response =
        await _httpService.fetchOutstandingBills(year: year);
    double totalMonthBills = 0;
    double totalYearlyBill = 0;
    if (!response['status']) return Future.value(null);
    List<dynamic> monthly = response['data']['monthly'];
    List<dynamic> yearly = response['data']['yearly'];
    for (int i = 0; i < monthly.length; i++) {
      List<dynamic> bill = monthly[i]['data'];
      bill.forEach((b) {
        double amount = double.parse(b["amount"]);
        totalMonthBills += amount;
      });
    }
    yearly.forEach((y) {
      double amount = double.parse(y["amount"]);
      totalYearlyBill += amount;
    });
    Map<String, dynamic> r = {"mb": totalMonthBills, "yb": totalYearlyBill};
    return Future.value(r);
  }

  //get user's payment information
  Future<Map<String, dynamic>> getPaymentInfo() async {
    Map<String, dynamic> _response = await _httpService.fetchPayments();
    if (!_response['status']) return Future.value(null);
    List<dynamic> r = _response['data'];
    String lastDate = r.length > 1
        ? DateFormat.yMMMMEEEEd().format(
            DateTime.parse(r[r.length - 1]["transaction"]["created_at"]))
        : "No payment made this year";
    Map<String, dynamic> paymentDetail = {
      "number_of_payments": r.length,
      "last_payment_date": lastDate
    };
    return Future.value(paymentDetail);
  }

  //fetch all user's request history
  Future<Map<String, dynamic>> getRequestsInfo() async {
    Map<String, dynamic> _response =
        await _httpService.fetchRequests(fetchAll: true);
    if (!_response['status']) return Future.value(null);
    List<dynamic> r = _response['data'];
    int completed = 0;
    int failed = 0;
    int pending = 0;
    r.forEach((data) {
      int statusId = int.parse(data['request_status_id']);
      if (statusId == 3)
        completed += 1;
      else if (statusId > 3)
        failed += 1;
      else
        pending += 1;
    });
    Map<String, dynamic> a = {
      "total": r.length,
      "completed": completed,
      "pending": pending,
      "failed": failed
    };
    return Future.value(a);
  }

  //call all associated methods to get information for the overview tab
  void overView() async {
    Map<String, dynamic> os = await getTotalOustanding();
    if (os == null)
      setState(() {
        outStanding = {
          "status": false,
          "message": "Error while fetching outstanding payments"
        };
      });
    else
      setState(() {
        outStanding = {"status": true, "message": "", "data": os};
      });

    List<dynamic> dependents = await fetchDependents();
    if (dependents == null)
      setState(() {
        dependentsInfo = {
          "status": false,
          "message": "Error while fetching dependents"
        };
      });
    else
      setState(() {
        dependentsInfo = {"status": true, "message": "", "data": dependents};
      });

    Map<String, dynamic> payment = await getPaymentInfo();
    if (payment == null)
      setState(() {
        paymentInfo = {
          "status": false,
          "message": "Error while fetching payment information"
        };
      });
    else
      setState(() {
        paymentInfo = {"status": true, "message": "", "data": payment};
      });

    Map<String, dynamic> requests = await getRequestsInfo();
    if (requests == null)
      setState(() {
        requestsInfo = {
          "status": false,
          "message": "Error while fetching requests information"
        };
      });
    else
      setState(() {
        requestsInfo = {"status": true, "message": "", "data": requests};
      });
  }

  @override
  void initState() {
    super.initState();
    _ctrlr = TabController(vsync: this, length: 3);
    _ctrlr.addListener(() {
      _activePage.value = _ctrlr.index;
    });
    overView();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _ctrlr.dispose();
    _activePage.dispose();
  }

  void openModal(BuildContext context, {String pageType = "edit"}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              backgroundColor: Colors.black54,
              body: SafeArea(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 20.0,
                          horizontal: 15.0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Form(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                //image widget was here. add image upload option here when
                                // backend has added support for image upload
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 40.0,
                                      ),
                                      pageType != 'dependents'
                                          ? TextFormField(
                                              controller: _surname,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "${pageType == 'visits' ? 'Visitors\' ' : ''}Surname",
                                              ),
                                              autocorrect: false,
                                            )
                                          : SizedBox(),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      pageType != 'dependents'
                                          ? TextFormField(
                                              controller: _othernames,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "${pageType == 'visits' ? 'Visitors\' ' : ''}Othernames",
                                              ),
                                              autocorrect: false,
                                            )
                                          : SizedBox(),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      pageType == 'visits'
                                          ? DateTimeField(
                                              controller: _visitDate,
                                              format: DateFormat("yyyy-MM-dd"),
                                              decoration: InputDecoration(
                                                  hintText: "Visit Date"),
                                              onShowPicker:
                                                  (context, currentValue) {
                                                return showDatePicker(
                                                    context: context,
                                                    firstDate: DateTime(1900),
                                                    initialDate: currentValue ??
                                                        DateTime.now(),
                                                    lastDate: DateTime(2100));
                                              },
                                            )
                                          : Column(children: <Widget>[
                                              TextFormField(
                                                controller: _phone,
                                                decoration: InputDecoration(
                                                  hintText:
                                                      '${pageType == 'dependents' ? 'Dependents ' : ''}Phone Number',
                                                ),
                                                keyboardType:
                                                    TextInputType.phone,
                                                autocorrect: false,
                                              ),
                                              pageType == 'dependents'
                                                  ? Column(children: <Widget>[
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      Container(
                                                        height: 60.0,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    10.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .all(
                                                                  Radius
                                                                      .circular(
                                                                          30.0)),
                                                          border: Border.all(
                                                              color:
                                                                  shedAppBlue300),
                                                        ),
                                                        child:
                                                            ValueListenableBuilder(
                                                          valueListenable:
                                                              _dependent,
                                                          builder: (context,
                                                              type, child) {
                                                            List _dep =
                                                                dependentsInfo[
                                                                    "data"];
                                                            return DropdownButtonHideUnderline(
                                                              child:
                                                                  DropdownButton(
                                                                isExpanded:
                                                                    true,
                                                                value: type,
                                                                hint: Text(
                                                                    "Select dependents"),
                                                                items: _dep.map(
                                                                    (item) {
                                                                  return DropdownMenuItem(
                                                                      child: Text(
                                                                          "${item.title}"),
                                                                      value: item
                                                                          .id
                                                                          .toString());
                                                                }).toList(),
                                                                onChanged:
                                                                    (val) {
                                                                  _dependent
                                                                          .value =
                                                                      val;
                                                                },
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ])
                                                  : SizedBox()
                                            ]),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      pageType == 'visits'
                                          ? TextFormField(
                                              controller: _phone,
                                              decoration: InputDecoration(
                                                hintText:
                                                    "Visitor's Phone Number",
                                              ),
                                              keyboardType: TextInputType.phone,
                                              autocorrect: false,
                                            )
                                          : SizedBox(),
                                      //dependent's relationship and gender widgets were here
                                      pageType == 'edit'
                                          ? TextFormField(
                                              controller: _email,
                                              decoration: InputDecoration(
                                                hintText: "Email",
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              autocorrect: false,
                                            )
                                          : SizedBox(),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      pageType == 'edit'
                                          ? TextFormField(
                                              controller: _address,
                                              decoration: InputDecoration(
                                                hintText: "Address",
                                              ),
                                              autocorrect: false,
                                            )
                                          : SizedBox(),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      pageType == 'edit'
                                          ? Container(
                                              decoration: ShapeDecoration(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  35.0)),
                                                      side: BorderSide(
                                                          width: 1.0,
                                                          style:
                                                              BorderStyle.solid,
                                                          color:
                                                              shedAppBlue300))),
                                              margin: EdgeInsets.only(
                                                  top: 0.0,
                                                  right: 0.0,
                                                  left: 0.0),
                                              width: double.infinity,
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 10.0, right: 10.0),
                                                  child: new DropdownButton<
                                                      String>(
                                                    value: _title,
                                                    items: <String>[
                                                      'Mr',
                                                      'Miss',
                                                      'Mrs'
                                                    ].map((String value) {
                                                      return new DropdownMenuItem<
                                                          String>(
                                                        value: value,
                                                        child: new Text(value),
                                                      );
                                                    }).toList(),
                                                    onChanged: (newValue) {
                                                      setState(() {
                                                        _title = newValue;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            )
                                          : SizedBox(),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      RaisedButton(
                                        child: _buttonClicked
                                            ? SizedBox(
                                                child: AuthButtonSpinner(
                                                    Colors.white),
                                                height: 20.0,
                                                width: 20.0,
                                              )
                                            : Text(pageType == "visits"
                                                ? "ADD VISIT"
                                                : pageType == "dependents"
                                                    ? "ADD DEPENDENT"
                                                    : "UPDATE PROFILE"),
                                        onPressed: () async {
                                          setState(() {
                                            _buttonClicked = true;
                                            _report['message'] = '';
                                          });
                                          Future<Map<String, dynamic>>
                                              profileUpdate =
                                              sortProfileFormData(
                                                  _email.text.trim(),
                                                  _surname.text.trim(),
                                                  _othernames.text.trim(),
                                                  _phone.text.trim(),
                                                  _visitDate.text.trim(),
                                                  _address.text.trim(),
                                                  _title,
                                                  _dependent.value,
                                                  pageType);
                                          profileUpdate.then((response) {
                                            setState(() {
                                              _report = response;
                                              _buttonClicked = false;
                                            });
                                          }).catchError((error) => setState(() {
                                                _report = {
                                                  "status": false,
                                                  "message":
                                                      "Sorry, there was an error while processing your request"
                                                };
                                                _buttonClicked = false;
                                              }));
                                        },
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Center(
                                        child: Text(_report["message"],
                                            style: TextStyle(
                                                color: _report["status"]
                                                    ? Colors.green[700]
                                                    : Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15.0)),
                                      ),
                                      SizedBox(
                                        height: 30.0,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: .5,
                        child: FloatingActionButton(
                          heroTag: "cls",
                          onPressed: () {
                            _picture.value = null;
                            _start.text = "";
                            _gender.text = "";
                            _relation.text = "";
                            _surname.text = "";
                            _othernames.text = "";
                            _phone.text = "";
                            _visitDate.text = "";
                            _email.text = "";
                            setState(() {
                              _buttonClicked = false;
                              _report = {"status": false, "message": ""};
                            });
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    formatter = NumberFormat.currency(
      name: "NGN",
      symbol: "NGN ",
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    );
    return FutureBuilder(
        future: _getUserProfile(),
        builder: (context, res) {
          if (res.hasError) {
            return Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    res.error
                        .toString(), //"An error occured. Please check your internet connection",
                    style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  )
                ],
              ),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/empty_state.png'),
                ),
              ),
            );
          }
          if (res.hasData) {
            UserProfileModel _userProfile = res.data;
            String displayImageUrl = _userProfile.user.pictureUrl;
            return Scaffold(
              backgroundColor: shedAppYellow50,
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: ValueListenableBuilder(
                valueListenable: _activePage,
                builder: (context, val, child) {
                  if (val != 0) {
                    return FloatingActionButton.extended(
                      label:
                          Text(val == 1 ? "Add Dependents" : "Schedule Visit"),
                      icon: Icon(
                        val == 1 ? Icons.person_add : Icons.verified_user,
                      ),
                      onPressed: () {
                        if (val == 1) {
                          if (userRoleId != '3') {
                            showDialog(
                              context: context,
                              builder: (_) {
                                return SizedBox(
                                    height: 80.0,
                                    child: AlertDialog(
                                      title: Text(
                                        'User account',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                      content: Text(
                                        'Sorry, you cannot create a user account',
                                        //style: TextStyle(fontSize: 14.0),
                                      ),
                                      actions: [
                                        FlatButton(
                                          child: Text(
                                            "Ok, thanks",
                                            style: TextStyle(
                                                color: shedAppBlue300),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    ));
                              },
                            );
                            return;
                          }
                        }
                        openModal(context,
                            pageType: val == 1 ? 'dependents' : 'visits');
                      },
                    );
                  }
                  return SizedBox(
                    height: 0,
                  );
                },
              ),
              body: NestedScrollView(
                headerSliverBuilder: (context, isScroll) {
                  return [
                    SliverAppBar(
                      floating: false,
                      pinned: true,
                      leading: BackButton(
                        color: Colors.white,
                      ),
                      centerTitle: true,
                      title: Text(
                        _userProfile.user.othernames == null
                            ? "No name yet"
                            : "${_userProfile.user.surname} ${_userProfile.user.othernames}",
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .copyWith(color: Colors.white),
                      ),
                      expandedHeight: MediaQuery.of(context).size.height * 0.5,
                      actions: <Widget>[
                        IconButton(
                          color: Colors.white,
                          icon: Icon(Icons.edit),
                          onPressed: () => openModal(context),
                        )
                      ],
                      backgroundColor: shedAppBlue400,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Hero(
                          tag: "Dirisu Jesseee",
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage("assets/img/loading.png"),
                                colorFilter: ColorFilter.mode(
                                  Colors.black54,
                                  BlendMode.darken,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  child: CircleAvatar(
                                    backgroundImage: (displayImageUrl == null ||
                                            displayImageUrl.length < 1)
                                        ? AssetImage("assets/img/loading.png")
                                        : NetworkImage(displayImageUrl),
                                    radius: 80,
                                  ),
                                  onTap: () async {
                                    var image = await ImagePicker.pickImage(
                                        source: ImageSource.gallery);
                                    var imageBytes = image.readAsBytesSync();
                                    String encodedImage =
                                        base64Encode(imageBytes);
                                    setState(() {
                                      renderSnackBar(context, shedAppBlue300,
                                          "Uploading image ....");
                                    });
                                    Map<String, dynamic> _response =
                                        await _httpService
                                            .uploadProfileImage(encodedImage);
                                    if (_response['status']) {
                                      setState(() {
                                        displayImageUrl = _response['data'];
                                      });
                                    } else {
                                      setState(() {
                                        renderSnackBar(context, Colors.red,
                                            _response['message']);
                                      });
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  _userProfile.user.address == null
                                      ? "No address yet"
                                      : _userProfile.user.address,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  _userProfile.property.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Text(
                                  _userProfile.property.address,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                RichText(
                                  text: TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                    children: [
                                      TextSpan(text: _userProfile.user.phone),
                                      TextSpan(text: " | "),
                                      TextSpan(
                                        text: _userProfile.user.email,
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: false,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelPadding: EdgeInsets.symmetric(vertical: 15),
                          controller: _ctrlr,
                          tabs: <Widget>[
                            Text(
                              "OVERVIEW",
                              style: TextStyle(color: shedAppBodyBlack),
                            ),
                            Text(
                              "DEPENDENTS",
                              style: TextStyle(color: shedAppBodyBlack),
                            ),
                            Text(
                              "VISITS",
                              style: TextStyle(color: shedAppBodyBlack),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _ctrlr,
                  children: <Widget>[
                    CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 200, top: 20),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate(
                              [
                                Container(
                                  height: 100,
                                  margin: EdgeInsets.only(
                                    left: 14.0,
                                    right: 14.0,
                                    top: 10.0,
                                    bottom: 5.0,
                                  ),
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10.0,
                                            left: 14.0,
                                            right: 14.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            "${DateTime.now().year} OUTSTANDING BILLS (YEARLY)",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            // .copyWith(color: Colors.white)
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: !outStanding["status"]
                                                ? outStanding["message"]
                                                            .length <
                                                        1
                                                    ? AppSpinner()
                                                    : Text(
                                                        "${outStanding['message']}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                : Text(
                                                    formatter.format(
                                                        outStanding['data']
                                                            ['yb']),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline
                                                        .copyWith(fontSize: 25),
                                                    textAlign: TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  margin: EdgeInsets.only(
                                    left: 14.0,
                                    right: 14.0,
                                    top: 10.0,
                                    bottom: 5.0,
                                  ),
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10.0,
                                            left: 14.0,
                                            right: 14.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            "${DateTime.now().year} OUTSTANDING BILLS (MONTHLY)",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            // .copyWith(color: Colors.white)
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: !outStanding["status"]
                                                ? outStanding["message"]
                                                            .length <
                                                        1
                                                    ? AppSpinner()
                                                    : Text(
                                                        "${outStanding['message']}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                : Text(
                                                    formatter.format(
                                                        outStanding['data']
                                                            ['mb']),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline
                                                        .copyWith(fontSize: 25),
                                                    textAlign: TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  margin: EdgeInsets.only(
                                    left: 14.0,
                                    right: 14.0,
                                    top: 10.0,
                                    bottom: 5.0,
                                  ),
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10.0,
                                            left: 14.0,
                                            right: 14.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            "LAST PAYMENT MADE THIS YEAR",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: !paymentInfo["status"]
                                                ? paymentInfo["message"]
                                                            .length <
                                                        1
                                                    ? AppSpinner()
                                                    : Text(
                                                        "${paymentInfo['message']}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                : Text(
                                                    "${paymentInfo['data']['last_payment_date']}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline
                                                        .copyWith(fontSize: 25),
                                                    textAlign: TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  margin: EdgeInsets.only(
                                    left: 14.0,
                                    right: 14.0,
                                    top: 10.0,
                                    bottom: 5.0,
                                  ),
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10.0,
                                            left: 14.0,
                                            right: 14.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            "REQUESTS",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: <Widget>[
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    "TOTAL",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${requestsInfo['data']['total']}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline
                                                          .copyWith(
                                                              fontSize: 25),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                color: shedAppBlue400,
                                                width: .5,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    "COMPLETED",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${requestsInfo['data']['completed']}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline
                                                          .copyWith(
                                                              fontSize: 25),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                color: shedAppBlue400,
                                                width: .5,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    "PENDING",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${requestsInfo['data']['pending']}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline
                                                          .copyWith(
                                                              fontSize: 25),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                color: shedAppBlue400,
                                                width: .5,
                                                margin: EdgeInsets.symmetric(
                                                    vertical: 10.0),
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  Text(
                                                    "FAILED",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(fontSize: 12),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "${requestsInfo['data']['failed']}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline
                                                          .copyWith(
                                                              fontSize: 25),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  margin: EdgeInsets.only(
                                    left: 14.0,
                                    right: 14.0,
                                    top: 10.0,
                                    bottom: 5.0,
                                  ),
                                  child: Card(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.only(
                                            top: 10.0,
                                            left: 14.0,
                                            right: 14.0,
                                            bottom: 5.0,
                                          ),
                                          child: Text(
                                            "PAYMENTS MADE THIS YEAR",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: !paymentInfo["status"]
                                                ? paymentInfo["message"]
                                                            .length <
                                                        1
                                                    ? AppSpinner()
                                                    : Text(
                                                        "${paymentInfo['message']}",
                                                        style: TextStyle(
                                                            color: Colors.red),
                                                      )
                                                : Text(
                                                    "${paymentInfo["data"]["number_of_payments"]}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline
                                                        .copyWith(fontSize: 25),
                                                    textAlign: TextAlign.center,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 200, top: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, idx) {
                                UserModel dependent =
                                    _userProfile.childrenUser[idx];
                                return Card(
                                    elevation: 1,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    child: Container(
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            height: 100.0,
                                            decoration: BoxDecoration(
                                                color:
                                                    dependent.pictureUrl == null
                                                        ? shedAppBlue400
                                                        : null),
                                            child: dependent.pictureUrl == null
                                                ? Icon(
                                                    Icons.info_outline,
                                                    color: Colors.white,
                                                  )
                                                : Image.network(
                                                    dependent.pictureUrl,
                                                    fit: BoxFit.cover,
                                                    loadingBuilder: (BuildContext
                                                            context,
                                                        Widget child,
                                                        ImageChunkEvent
                                                            loadingProgress) {
                                                      if (loadingProgress ==
                                                          null) return child;
                                                      return Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              Colors.white,
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes
                                                              : null,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Wrap(children: <Widget>[
                                                    Icon(
                                                      Icons.person_outline,
                                                      size: 20.0,
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Text(dependent.othernames ==
                                                            null
                                                        ? "No name yet"
                                                        : "${dependent.surname} ${dependent.othernames}"),
                                                  ]),
                                                  Row(children: <Widget>[
                                                    Icon(
                                                      Icons.phone_in_talk,
                                                      size: 20.0,
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Text("${dependent.phone}"),
                                                  ]),
                                                  Row(children: <Widget>[
                                                    Icon(
                                                      Icons.group,
                                                      size: 20.0,
                                                    ),
                                                    SizedBox(width: 10.0),
                                                    Text(
                                                        "${dependent.relationship}"),
                                                  ]),
                                                ]),
                                          )
                                        ],
                                      ),
                                    ));
                              },
                              childCount: _userProfile.childrenUser.length,
                            ),
                          ),
                        )
                      ],
                    ),
                    CustomScrollView(
                      slivers: <Widget>[
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 200, top: 20),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, idx) {
                                VisitModel _visit = _userProfile.visits[idx];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 13,
                                    ),
                                    constraints: BoxConstraints(maxHeight: 130),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 10),
                                          child: Column(
                                            children: <Widget>[
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: shedAppBlue50,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              shedAppYellow400,
                                                          width: 1)),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                height: 10,
                                                width: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: shedAppErrorRed,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                "Added at : ${DateFormat.yMMMd().format(DateTime.parse(_visit.createdAt))}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle,
                                              ),
                                              SizedBox(height: 7.0),
                                              Text(
                                                "${_visit.visitorName}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 7.0),
                                              Text(
                                                "${_visit.visitorPhone}",
                                              ),
                                              SizedBox(
                                                height: 7.0,
                                              ),
                                              Text(
                                                "Expected on : ${DateFormat.yMMMd().format(DateTime.parse(_visit.expectedVisitTime))}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              childCount: _userProfile.visits.length,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Container(color: Colors.white, child: AppSpinner());
          }
        });
  }

  renderSnackBar(BuildContext context, Color bgColor, String content) {
    Scaffold.of(context).showSnackBar(SnackBar(
      backgroundColor: bgColor,
      content: Text(
        content,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ));
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 3,
          spreadRadius: 2,
        )
      ]),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
