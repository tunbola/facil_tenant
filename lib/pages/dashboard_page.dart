import 'dart:async';

import 'package:facil_tenant/models/message_model.dart';
import 'package:flutter/material.dart';
import 'package:facil_tenant/components/image_button.dart';
import '../components/app_scaffold.dart';

import 'package:overlay_support/overlay_support.dart';

import '../styles/colors.dart';

final List<MessageModel> messages = [
  MessageModel(
    isRead: false,
    title: "November Bills",
    body: "Your bills for november are due",
    createdAt: DateTime.now(),
  ),
  MessageModel(
    isRead: false,
    title: "Rent Increment",
    body: "Rent will be increased by 10%",
    createdAt: DateTime.now(),
  ),
  MessageModel(
    isRead: false,
    title: "Welcome to Aso Rock",
    body: "I welcome you Dirisu Jesse to Aso Rock villa",
    createdAt: DateTime.now(),
  ),
  MessageModel(
    isRead: false,
    title: "Payment Received",
    body: "Your bill payments were well received for October",
    createdAt: DateTime.now(),
  ),
];

class DashboardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DashboardPageState();
  }
}

//Displays notifications overlay at the top of the screen
//stacked on one another.
class _DashboardPageState extends State<DashboardPage> {
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
                    child: Text("AB"),
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

  @override
  void initState() {
    super.initState();
    showNotifs(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      auomaticallyImplyLeading: false,
      pageTitle: ValueNotifier("DASHBOARD"),
      actions: <Widget>[
        IconButton(
          icon: Icon(Icons.power_settings_new),
          onPressed: () => Navigator.of(context).pushReplacementNamed('auth'),
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
                    "DIRISU JESSE BAYODELE",
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
                    "Aso Rock Villa",
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.display1.copyWith(
                          fontSize: 25,
                        ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 10,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 90),
              child: ImageButton(
              "assets/img/megaphone.png",
              caption: "Announcements",
              textStyle: TextStyle(fontSize: 10),
              onPress: () => Navigator.of(context).pushNamed('announcements'),
            ),
            ),
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
                      Navigator.of(context).pushNamed('outstandings'),
                ),
                ImageButton(
                  "assets/img/chat.png",
                  caption: "Messages",
                  onPress: () =>
                      Navigator.of(context).pushNamed('notifications'),
                ),
                ImageButton(
                  "assets/img/sent_message.png",
                  caption: "Requests/Complaints",
                  onPress: () => Navigator.of(context).pushNamed('complaints'),
                ),
                ImageButton(
                  "assets/img/verified_payment.png",
                  caption: "Payments",
                  onPress: () =>
                      Navigator.of(context).pushNamed('payment/history'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
