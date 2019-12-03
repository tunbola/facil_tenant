import 'package:facil_tenant/models/index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/message_model.dart';
import 'package:facil_tenant/models/user_model.dart';
import "package:facil_tenant/services/http_service.dart";
import 'package:facil_tenant/styles/colors.dart';

/*


{
    "id": "10", 
    "request_type_id": "3", 
    "user_id": "5", 
    "comment": "I suggest monthly payment for sewage disposal so as to have a great.", 
    "created_at": "2019-10-31 10:00:50", 
    "last_updated": "2019-11-04 15:39:54", 
    "request_status_id": "3", 
    "requestStatus": {id: 3, name: Completed}, 
    "requestType": {id: 3, property_id: 1, name: Requests, request_group_id: null}
}

*/

//Requests/complaints page
class NotificationsPage extends StatefulWidget {
  final bool isRequests;
  final bool isAnnouncements;

  NotificationsPage({this.isRequests = false, this.isAnnouncements = false});

  @override
  State<StatefulWidget> createState() {
    return _NotificationsPageState();
  }
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: widget.isRequests
          ? FloatingActionButton.extended(
              heroTag: "createMessae",
              tooltip: "Create Message",
              onPressed: () =>
                  Navigator.of(context).pushNamed("notifications/create"),
              icon: Icon(Icons.edit),
              label: Text("Make a Request"),
            )
          : null,
      child: NotificationsList(
          isRequest: widget.isRequests,
          isAnnouncements: widget.isAnnouncements),
      pageTitle: ValueNotifier(widget.isRequests ? "REQUESTS" : "ANNOUCEMENTS"),
    );
  }
}

class NotificationsList extends StatelessWidget {
  final bool isRequest;
  final bool isAnnouncements;
  NotificationsList({this.isRequest = false, this.isAnnouncements});

  final _httpService = new HttpService();

  Future<List<NotificationsModel>> _getNotifications() async {
    //Map<String, dynamic> re = await _httpService.fetchRequests("1");
    //print(re);
    if (this.isAnnouncements) {
      Map<String, dynamic> response =
          await _httpService.fetchAnnounceMents("1");
      List<NotificationsModel> _notifications =
          (response["data"]["data"] as List)
              .map((data) => NotificationsModel(
                  id: data["id"],
                  message: data["notice"],
                  createdAt: data["created_at"]))
              .toList();
      return Future.value(_notifications);
    }
    return [];

    /*return Future.value(
      List.generate(
        30,
        (idx) => MessageModel(
          id: idx.toString(),
          title: "My Roof Leaks",
          isRead: false,
          body:
              """Harmful interruptions take a large toll. An average person gets interrupted
               many times an hour, has multiple windows open on their computer, checks their email repeatedly, 
               feels that half of their time in meetings is unproductive, and spends a large part of their working time 
               simply looking for the information they need to do their job.""",
          createdAt: DateTime.now(),
          to: "Dirisu Jesse",
          from: UserModel(
            email: "tenant@facil.com",
            pictureUrl: "assets/img/media.png",
            surname: "Ogbeni Ayalegbe",
            othernames: "",
            phone: "+234 820 022 6425",
          ),
        ),
      ),
    );*/
  }

  /*{status: true, message: Announcements, 
  data: {totalRows: 10, data: [{id: 10, property_id: 2, notice: udhgfuhdifhgihdfighiuhidg, created_at: 2019-11-13 16:59:51}], 
  numberOfPages: 10, currentPage: 1, numberPerPage: 1}}*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getNotifications(),
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
          dynamic _notifications = res.data;
          return ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: res.data.length,
            itemBuilder: (context, idx) {
              final content = _notifications[idx];
              final bool isEven = idx % 2 == 0;
              return Dismissible(
                key: Key(idx.toString()),
                child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.0,
                      ),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // CircleAvatar(
                          //   backgroundColor: shedAppBlue300,
                          //   child: Text(
                          //     names.length > 1
                          //         ? "${names[0][0]}${names[1][0]}"
                          //         : "${names[0][0]}${names[0][1]}",
                          //     textAlign: TextAlign.center,
                          //     style:
                          //         Theme.of(context).textTheme.body1.copyWith(
                          //               fontWeight: FontWeight.w900,
                          //               color: Colors.white,
                          //             ),
                          //   ),
                          //   radius: 25.0,
                          // ),
                          // SizedBox(
                          //   width: 10.0,
                          // ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: 14.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: idx != (res.data.length - 1)
                                        ? BorderSide(
                                            color: Colors.grey, width: 0.5)
                                        : BorderSide.none),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Table(
                                    columnWidths: {
                                      0: FlexColumnWidth(6),
                                      1: FlexColumnWidth(3)
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Text(
                                            isRequest
                                                ? "${content.requestType}"
                                                : "",
                                            maxLines: 1,
                                            style: Theme.of(context)
                                                .textTheme
                                                .title,
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            DateFormat.yMEd().format(
                                                DateTime.parse(
                                                    content.createdAt)),
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body1
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  isRequest
                                      ? Text(
                                          "${isEven ? 'RESOLVED' : 'UNRESOLVED'}",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isEven
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                        ),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Text(
                                    content.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {}),
                onDismissed: (dir) => "",
                direction: DismissDirection.endToStart,
              );
            },
          );
        } else {
          return AppSpinner();
        }
      },
    );
  }
}
