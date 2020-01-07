import 'dart:async';

import 'package:facil_tenant/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:facil_tenant/components/image_button.dart';
import '../components/app_scaffold.dart';

import 'package:overlay_support/overlay_support.dart';

import '../styles/colors.dart';

import "package:facil_tenant/services/access_service.dart";

import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

final List<MessageModel> messages = [];

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DashboardPageState();
  }
}

//Displays notifications overlay at the top of the screen
//stacked on one another.
class _DashboardPageState extends State<DashboardPage> {
  String _username = "";
  String _propertyName = "";
  String _propertyAddress = "";

  static NavigationService _navigationService = locator<NavigationService>();

  void showNotifs(BuildContext context) {
    Timer(Duration(seconds: 1), () {
      messages.forEach((message) {
        showOverlayNotification(
          (context) {
            return SafeArea(
              minimum: EdgeInsets.only(top: 130),
              child: Card(
                elevation: 0,
                color: shedAppYellow100,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: shedAppBlue400,
                    child: Text("NB"),
                  ),
                  title: Text(
                    message.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20),
                  ),
                  subtitle: Text(
                    message.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => OverlaySupportEntry.of(context).dismiss(),
                  ),
                ),
              ),
            );
          },
          duration: Duration(
            milliseconds: 0,
          ),
        );
      });
    });
  }

  getUserName() async {
    String un = await AccessService.getUserName();
    setState(() {
      _username = un;
      if (un == "No name yet") {
        messages.add(MessageModel(
          isRead: false,
          title: "Profile",
          body: "Please click on the user icon above to update your profile",
          createdAt: DateTime.now(),
        ));
      }
    });
  }

  getProperty() async {
    Map<String, dynamic> property = await AccessService.getProperty();
    setState(() {
      _propertyName = property["name"];
      _propertyAddress = property["address"];
    });
  }

  @override
  void initState() {
    super.initState();
    showNotifs(context);
    getUserName();
    getProperty();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      auomaticallyImplyLeading: false,
      pageTitle: ValueNotifier("DASHBOARD"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.power_settings_new),
          onPressed: () => AccessService
              .logOut(), // Navigator.of(context).pushReplacementNamed('auth'), //logout here
          iconSize: 30,
        ),
      ],
      child: Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
              horizontal: 14.0,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _username.toUpperCase(),
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.title.copyWith(
                          fontSize: 50.0,
                          color: shedAppBlue300,
                        ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    _propertyName,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.display1.copyWith(
                          fontSize: 25.0,
                        ),
                  ),
                  Text(
                    _propertyAddress,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.display1.copyWith(
                          fontSize: 17.0,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(0.0)),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 90),
                child: ImageButton(
                    "assets/img/loud-speaker-1167348_640.png",
                    caption: "Announcements",
                    textStyle: TextStyle(fontSize: 10),
                    onPress: () =>
                        _navigationService.navigateTo(routes.Announcements),
                  ),),
            )
          ),
        ],
      ),
      bottomWidget: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.3,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(
              children: [
                ImageButton(
                  "assets/img/receipt.png",
                  caption: "Bills",
                  onPress: () =>
                      _navigationService.navigateTo(routes.OutstandingBills),
                ),
                ImageButton(
                  "assets/img/chat.png",
                  caption: "Messages",
                  onPress: () => _navigationService.navigateTo(routes.Messages),
                ),
                ImageButton(
                  "assets/img/sent_message.png",
                  caption: "Requests",
                  onPress: () =>
                      _navigationService.navigateTo(routes.Complaints),
                ),
                ImageButton(
                  "assets/img/verified_payment.png",
                  caption: "Payments",
                  onPress: () =>
                      _navigationService.navigateTo(routes.PaymentHistory),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
