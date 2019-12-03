import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/styles/colors.dart';
//import 'package:image_picker/image_picker.dart';
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
  //TextEditingController _end = TextEditingController(text: "");
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

  HttpService _httpService = new HttpService();
  bool _buttonClicked = false;
  Map<String, dynamic> _report = {"status": false, "message": ""};

  Future<UserProfileModel> _getUserProfile() async {
    String userId = await AccessService.getUserId();

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
      String pageType) async {
    if (pageType == "visits") {
      //call method to add property access
      return await createVisit(surname, othernames, phone, visitDate);
    }

    if (pageType == "dependents") {
      if (AccessService.isPhoneNumber(phone)) {
        return await _httpService.createDependentUser(phone);
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
    /*return {
      "status": true,
      "message": "$surname, $othernames, $phone, $email, $address, $title",
      "pageType": "Page type is Edit"
    };*/
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

  @override
  void initState() {
    super.initState();
    _ctrlr = TabController(vsync: this, length: 3);
    _ctrlr.addListener(() {
      _activePage.value = _ctrlr.index;
    });
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
                                          : TextFormField(
                                              controller: _phone,
                                              decoration: InputDecoration(
                                                hintText:
                                                    '${pageType == 'dependents' ? 'Dependents ' : ''}Phone Number',
                                              ),
                                              keyboardType: TextInputType.phone,
                                              autocorrect: false,
                                            ),
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
                                        onPressed: () {
                                          setState(() {
                                            _buttonClicked = true;
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
                                                      "Sorry, there was an error while processing your request $error"
                                                };
                                                _buttonClicked = false;
                                              }));
                                        },
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Text(_report["message"],
                                          style: TextStyle(
                                              color: _report["status"]
                                                  ? Colors.greenAccent
                                                  : Colors.redAccent,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15.0)),
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
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/img/empty_state.png'),
                ),
              ),
            );
          }
          if (res.hasData) {
            UserProfileModel _userProfile = res.data;
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
                                CircleAvatar(
                                  backgroundImage: AssetImage(
                                    "assets/img/loading.png",
                                  ),
                                  radius: 80,
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
                    /*SliverPersistentHeader(
                      pinned: true,
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
                    ),*/
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
                                            "OUTSTANDING BILLS",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            // .copyWith(color: Colors.white)
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              formatter.format(200),
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
                                            "LAST PAY DATE",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              DateFormat.yMMMMEEEEd()
                                                  .format(DateTime.now()),
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
                                            "COMPLAINTS",
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
                                                        .copyWith(fontSize: 14),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "10",
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
                                                    "OPEN",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(fontSize: 14),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "0",
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
                                                    "CLOSED",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(fontSize: 14),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      "10",
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
                                            "PAYMENTS",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              "20",
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
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: shedAppBlue100,
                                      child: Text(dependent.othernames == null
                                          ? "NN"
                                          : "${dependent.surname[0]}${dependent.othernames[0]}"),
                                      radius: 30,
                                    ),
                                    title: Text(dependent.othernames == null
                                        ? "No name yet"
                                        : "${dependent.surname} ${dependent.othernames}"),
                                    subtitle: Text(dependent.phone),
                                    trailing: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.delete_forever,
                                        color: shedAppBodyBlack,
                                      ),
                                    ),
                                  ),
                                );
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
                                  margin: EdgeInsets.symmetric(
                                      vertical: 5, horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 13,
                                    ),
                                    constraints: BoxConstraints(maxHeight: 100),
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
                                            children: <Widget>[
                                              Text(
                                                "Added at : ${DateFormat.yMMMd().format(DateTime.parse(_visit.createdAt))}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle,
                                              ),
                                              Expanded(
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "${_visit.visitorName}",
                                                    textAlign: TextAlign.start,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .title,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                "${_visit.visitorPhone}",
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                "Expected at : ${DateFormat.yMMMd().format(DateTime.parse(_visit.expectedVisitTime))}",
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
            return AppSpinner();
          }
        });
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
