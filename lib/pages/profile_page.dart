import 'package:facil_tenant/styles/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

const List<String> relations = [
  "Spouse",
  "Child",
  "Parent",
  "Sibling",
  "Friend"
];

const List<String> genders = ["Male", "Female"];

NumberFormat formatter;

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  ValueNotifier<int> _activePage = ValueNotifier(0);
  TextEditingController _start = TextEditingController(text: "");
  // TextEditingController _end = TextEditingController(text: "");
  TextEditingController _gender = TextEditingController(text: "");
  TextEditingController _relation = TextEditingController(text: "");
  ValueNotifier _picture = ValueNotifier(null);
  TabController _ctrlr;

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
                            Center(
                              child: GestureDetector(
                                child: ValueListenableBuilder(
                                  valueListenable: _picture,
                                  builder: (context, pic, child) {
                                    return CircleAvatar(
                                      backgroundColor: shedAppYellow50,
                                      backgroundImage: pic == null
                                          ? pageType == "edit"
                                              ? AssetImage(
                                                  "assets/img/loading.png",
                                                )
                                              : null
                                          : FileImage(pic),
                                      child: pic == null
                                          ? pageType != "edit"
                                              ? Icon(
                                                  Icons.add_a_photo,
                                                  size: 40,
                                                  color: shedAppBodyBlack,
                                                )
                                              : null
                                          : null,
                                      radius: 100,
                                    );
                                  },
                                ),
                                onTap: () {
                                  ImagePicker.pickImage(
                                          source: ImageSource.gallery)
                                      .then((img) {
                                    _picture.value = img;
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            TextField(
                              decoration: InputDecoration(
                                hintText:
                                    "${pageType == 'visits' ? 'Visitors\' ' : pageType == 'dependents' ? 'Dependents\' ' : ''}Name",
                              ),
                              autocorrect: false,
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            pageType == 'visits'
                                ? GestureDetector(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: shedAppBlue300, width: 1),
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 10),
                                      child: ValueListenableBuilder(
                                        valueListenable: _start,
                                        builder: (context, date, child) {
                                          return Text(date.text != ''
                                              ? date.text
                                              : 'Visit Date');
                                        },
                                      ),
                                    ),
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate:
                                            DateTime(DateTime.now().year),
                                        lastDate:
                                            DateTime(DateTime.now().year + 5),
                                      ).then(
                                        (date) =>
                                            _start.value = TextEditingValue(
                                          text: date.toString(),
                                        ),
                                      );
                                    },
                                  )
                                : TextField(
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
                            pageType == 'dependents' ? TextField(
                              decoration: InputDecoration(
                                hintText: 'Dependents Email',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                            ) : SizedBox(),
                            SizedBox(
                              height: pageType == 'dependents' ? 10.0 : 0,
                            ),
                            pageType == 'visits'
                                ? TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Visitors Phone Number',
                                    ),
                                    keyboardType: TextInputType.phone,
                                    autocorrect: false,
                                  )
                                : SizedBox(),
                            pageType == 'dependents'
                                ? Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 5),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text('Relation to Dependent'),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: _relation,
                                          builder: (context, val, child) {
                                            return Wrap(
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              direction: Axis.horizontal,
                                              children: relations.map(
                                                (relation) {
                                                  return GestureDetector(
                                                    child: AnimatedContainer(
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      margin: EdgeInsets.only(
                                                        right: 5,
                                                        bottom: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: val.text ==
                                                                relation
                                                            ? shedAppBlue50
                                                            : shedAppYellow100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(relation),
                                                      duration: Duration(
                                                          milliseconds: 500),
                                                    ),
                                                    onTap: () {
                                                      _relation.value =
                                                          TextEditingValue(
                                                              text: relation);
                                                    },
                                                  );
                                                },
                                              ).toList(),
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text('Dependents Gender'),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        ValueListenableBuilder(
                                          valueListenable: _gender,
                                          builder: (context, val, child) {
                                            return Wrap(
                                              alignment: WrapAlignment.start,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              direction: Axis.horizontal,
                                              children: genders.map(
                                                (gender) {
                                                  return GestureDetector(
                                                    child: AnimatedContainer(
                                                      padding:
                                                          EdgeInsets.all(15),
                                                      margin: EdgeInsets.only(
                                                        right: 5,
                                                        bottom: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: val.text ==
                                                                gender
                                                            ? shedAppBlue50
                                                            : shedAppYellow100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(gender),
                                                      duration: Duration(
                                                        milliseconds: 500,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      _gender.value =
                                                          TextEditingValue(
                                                        text: gender,
                                                      );
                                                    },
                                                  );
                                                },
                                              ).toList(),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            pageType == 'edit'
                                ? TextField(
                                    decoration: InputDecoration(
                                      hintText: "Email",
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    autocorrect: false,
                                  )
                                : SizedBox(),
                            SizedBox(
                              height: 20.0,
                            ),
                            RaisedButton(
                              child: Text(pageType == "visits"
                                  ? "ADD VISIT"
                                  : pageType == "dependents"
                                      ? "ADD DEPENDENT"
                                      : "UPDATE PROFILE"),
                              onPressed: () => "",
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

  @override
  Widget build(BuildContext context) {
    formatter = NumberFormat.currency(
      name: "NGN",
      symbol: "NGN ",
      decimalDigits: 2,
      locale: Localizations.localeOf(context).toString(),
    );
    return Scaffold(
      backgroundColor: shedAppYellow50,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: _activePage,
        builder: (context, val, child) {
          if (val != 0) {
            return FloatingActionButton.extended(
              label: Text(val == 1 ? "Add Dependents" : "Schedule Visit"),
              icon: Icon(
                val == 1 ? Icons.person_add : Icons.verified_user,
              ),
              onPressed: () => openModal(context,
                  pageType: val == 1 ? 'dependents' : 'visits'),
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
                "DIRISU JESSE BAYODELE",
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
                  tag: "Dirisu Jesse",
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
                          "Apartment 2, Aso Villa, 2 Bode Thomas Road, Ilupeju, Lagos.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.body1.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.body1.copyWith(
                                  color: Colors.white,
                                ),
                            children: [
                              TextSpan(text: "0810011534"),
                              TextSpan(text: " | "),
                              TextSpan(
                                text: "djay@mail.com",
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: Theme.of(context).textTheme.body2,
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
                                          .copyWith(fontSize: 30),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: Theme.of(context).textTheme.body2,
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
                                          .copyWith(fontSize: 30),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: Theme.of(context).textTheme.body2,
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
                                                  .copyWith(fontSize: 30),
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
                                                  .copyWith(fontSize: 30),
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
                                                  .copyWith(fontSize: 30),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    style: Theme.of(context).textTheme.body2,
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
                                          .copyWith(fontSize: 30),
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
                        return Card(
                          elevation: 1,
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: shedAppBlue100,
                              child: Text("DR"),
                              radius: 30,
                            ),
                            title: Text("Dirisu Rhoda"),
                            subtitle: Text("Sister"),
                            trailing: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.delete_forever,
                                color: shedAppBodyBlack,
                              ),
                            ),
                            onTap: () {
                              _gender.text = "Female";
                              _relation.text = "Sibling";
                              openModal(context, pageType: 'dependents');
                            },
                          ),
                        );
                      },
                      childCount: 20,
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
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 13,
                            ),
                            constraints: BoxConstraints(maxHeight: 100),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                      // SizedBox(height: 5,),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: shedAppYellow400,
                                                  width: 1)),
                                        ),
                                      ),
                                      // SizedBox(height: 5,),
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
                                        "${DateFormat.yMMMd().format(DateTime.now().subtract(Duration(days: 10)))}",
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle,
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Visited by Dirisu Rhoda",
                                            textAlign: TextAlign.start,
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "${DateFormat.yMMMd().format(DateTime.now())}",
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
                      childCount: 20,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
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
