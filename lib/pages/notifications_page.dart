import 'package:facil_tenant/models/index.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import "package:facil_tenant/services/http_service.dart";
import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

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

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      floatingActionButton: widget.isRequests
          ? FloatingActionButton.extended(
              heroTag: "Notification",
              tooltip: "Requests & announcements",
              onPressed: () =>
                  _navigationService.navigateTo(routes.CreateRequest),
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

class NotificationsList extends StatefulWidget {
  final bool isRequest;
  final bool isAnnouncements;
  NotificationsList({this.isRequest = false, this.isAnnouncements});
  @override
  _NotificationsListState createState() =>
      _NotificationsListState(this.isRequest, this.isAnnouncements);
}

class _NotificationsListState extends State<NotificationsList> {
  final bool isRequest;
  final bool isAnnouncements;

  int _nextPage = 1;
  int _numberOfPages = 0;
  int _currentPage = 0;

  List<NotificationsModel> _notificationsList;

  _NotificationsListState(this.isRequest, this.isAnnouncements);

  final _httpService = new HttpService();
  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    super.initState();    
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_nextPage <= _numberOfPages) {
          await _getNotifications(_nextPage);
          setState(() {});
        }
      }
    });
  }

  Future<List<NotificationsModel>> _getNotifications(int pageNumber) async {
    List<NotificationsModel> _newList;
  
    //if next page is current page, return existing content
    if (_currentPage == _nextPage) {
      return Future.value(_notificationsList);
    }
  
    if (this.isAnnouncements) {
      Map<String, dynamic> response =
          await _httpService.fetchAnnounceMents(pageNumber);
      _newList = (response["data"]["data"] as List)
          .map((data) => NotificationsModel(
              id: data["id"],
              message: data["notice"],
              createdAt: data["created_at"]))
          .toList();
      _currentPage = int.parse(response["data"]["currentPage"].toString());
    } else {
      Map<String, dynamic> response =
          await _httpService.fetchRequests(pageNumber: pageNumber);
      _numberOfPages = int.parse(response["data"]["numberOfPages"].toString());

      _newList = (response["data"]["data"] as List)
          .map((data) => NotificationsModel(
              id: data["id"],
              message: data["comment"],
              createdAt: data["created_at"],
              lastUpdated: data["last_updated"],
              requestStatus: data["requestStatus"]["name"],
              requestStatusId: int.parse(data["requestStatus"]["id"].toString()),
              requestType: data["requestType"]["name"]))
          .toList();
      _currentPage = int.parse(response["data"]["currentPage"].toString());
    }
    _nextPage = _nextPage < _numberOfPages ? ++_nextPage : _numberOfPages;
    _notificationsList = (_notificationsList == null || _nextPage == 1)
        ? _newList
        : [..._notificationsList, ..._newList];
    return Future.value(_notificationsList);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getNotifications(_nextPage),
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
              child: Column(children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
                Text(
                  "Sorry, no content was found !",
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold),
                )
              ]),
            );
          }
          dynamic _notifications = res.data;
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(0),
            itemCount: res.data.length,
            itemBuilder: (context, idx) {
              final content = _notifications[idx];
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
                                      0: FlexColumnWidth(5),
                                      1: FlexColumnWidth(4)
                                    },
                                    children: [
                                      TableRow(
                                        children: [
                                          Text(
                                            isRequest
                                                ? "${content.requestType}"
                                                : "",
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            textAlign: TextAlign.left,
                                          ),
                                          Text(
                                            "On : ${DateFormat.yMEd().format(DateTime.parse(content.createdAt))}",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.bold),
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
                                          "${content.requestStatus}",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: content.requestStatusId < 3
                                                ? Colors.blue
                                                : content.requestStatusId == 3
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
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body1
                                        .copyWith(
                                            fontWeight: FontWeight.normal),
                                  ),
                                  SizedBox(
                                    height: 7.0,
                                  ),
                                  isRequest
                                      ? Table(
                                          columnWidths: {
                                            0: FlexColumnWidth(5),
                                            1: FlexColumnWidth(4)
                                          },
                                          children: [
                                            TableRow(
                                              children: [
                                                Text(
                                                  "",
                                                ),
                                                Text(
                                                  "Updated : ${content.lastUpdated == null ? 'Not yet tended to' : DateFormat.yMEd().format(DateTime.parse(content.lastUpdated))}",
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                      fontSize: 12.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : SizedBox(
                                          height: 0,
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
