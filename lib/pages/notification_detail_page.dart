import 'package:flutter/material.dart';
// import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/message_model.dart';
// import 'package:facil_tenant/styles/colors.dart';
import '../components/app_scaffold.dart';

class NotificationDetailPage extends StatelessWidget {
  final MessageModel message;
  final bool isFromMe;
  final bool isAnnouncement;

  NotificationDetailPage({
    @required this.message,
    @required this.isFromMe,
    this.isAnnouncement = false,
  }) : assert(message != null && isFromMe != null);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: isFromMe ? FloatingActionButton.extended(
        icon: Icon(Icons.check),
        label: Text("Mark as Resolved"),
        onPressed: () {},
      ) : null,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                message.title,
                style: Theme.of(context).textTheme.title.copyWith(fontSize: 30),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "${isFromMe ? 'to' : 'from'} ${isFromMe ? message.to : message.from.surname}",
                style: Theme.of(context).textTheme.subtitle,
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                message.body,
                textAlign: TextAlign.left,
                softWrap: true,
              ),
              isAnnouncement ? SizedBox() : SizedBox(
                height: 40.0,
              ),
              isAnnouncement ? SizedBox() : TextField(
                maxLines: 5,
              ),
              isAnnouncement ? SizedBox() : SizedBox(
                height: 10.0,
              ),
              isAnnouncement ? SizedBox() : RaisedButton(
                  // padding: EdgeInsets.all(15.0),
                  onPressed: () => "",
                  child: Text("Reply"),
                ),
              isAnnouncement ? SizedBox() : SizedBox(
                height: 10.0,
              ),
              isAnnouncement ? SizedBox() : ExpansionTile(
                title: Text("Replies"),
                children: <Widget>[
                  Center(
                    child: Image.asset("assets/img/empty_state.png"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      pageTitle: ValueNotifier(message.title),
    );
  }
}