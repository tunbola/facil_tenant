import 'package:facil_tenant/models/index.dart';
import 'package:facil_tenant/pages/update_notification_page.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import "package:facil_tenant/services/http_service.dart";
import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;
import 'package:url_launcher/url_launcher.dart';

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
              label: Text("New Request"),
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

  bool isLoading = false;

  List<NotificationsModel> _notificationsList = [];

  var _scaffoldKey = new GlobalKey<ScaffoldState>();

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
    List<NotificationsModel> _newList = [];
    //if next page is current page, return existing content
    if (_currentPage == _nextPage) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("No more contents"),
      ));
      return Future.value(_notificationsList);
    }
    if (_notificationsList.length > 1) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please wait ... Fetching requests"),
      ));
    }
    if (this.isAnnouncements) {
      Map<String, dynamic> response =
          await _httpService.fetchAnnounceMents(pageNumber);
      if (!response['status']) return Future.value(_newList);
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
      if (!response['status']) return Future.value(_newList);
      _numberOfPages = int.parse(response["data"]["numberOfPages"].toString());
      _newList = (response["data"]["data"] as List)
          .map((data) => NotificationsModel(
              id: data["id"],
              message: data["comment"],
              createdAt: data["created_at"],
              lastUpdated: data["last_updated"],
              requestStatus: data["requestStatus"]["name"],
              requestStatusId:
                  int.parse(data["requestStatus"]["id"].toString()),
              requestType: data["requestType"]["name"],
              attachmentUrl: data['attachment_url']))
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
    return Scaffold(
        key: _scaffoldKey,
        body: FutureBuilder(
            future: _getNotifications(_nextPage),
            builder: (context, res) {
              if (res.hasError) {
                return Container(
                  child: Center(
                    child: Text(
                      "Error occured ...",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
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
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold),
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
                      return Container(
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: notificationBody(isRequest, content, context),
                      );
                    });
              } else {
                return AppSpinner();
              }
            }));
  }

  Widget notificationBody(
      bool isRequest, NotificationsModel content, BuildContext context) {
    int messageLength = content.message.length;
    if (!isRequest) {
      return Card(
        child: InkWell(
          child: ListTile(
            isThreeLine: true,
            title: Text(
                "${DateFormat.yMMMEd().format(DateTime.parse(content.createdAt))}"),
            subtitle: messageLength < 100
                ? Text("${content.message}")
                : Text("${content.message.substring(0, 100)}"),
            trailing: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 30.0,
                  )
                ],
              ),
              decoration: BoxDecoration(
                  border: new Border(
                      left: new BorderSide(width: 1.0, color: Colors.grey))),
            ),
          ),
          onTap: () {
            showNotificationDialog(context, content, isRequest);
          },
        ),
      );
    }
    Color color = content.requestStatusId < 3
        ? shedAppBlue300
        : content.requestStatusId == 3 ? Colors.green : Colors.red;
    return Card(
        child: InkWell(
      child: ListTile(
        isThreeLine: true,
        title: Text("${content.requestType}"),
        subtitle: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: 10.0,
                  width: 10.0,
                  decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.all(Radius.circular(30.0))),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Text("${content.requestStatus}")
              ],
            ),
            SizedBox(
              height: 5.0,
            ),
            messageLength < 100
                ? Text("${content.message}")
                : Text("${content.message.substring(0, 70)} ..."),
            SizedBox(
              height: 5.0,
            )
          ],
        ),
        trailing: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                Icons.keyboard_arrow_right,
                size: 30.0,
              )
            ],
          ),
          decoration: BoxDecoration(
              border: new Border(
                  left: new BorderSide(width: 1.0, color: Colors.grey))),
        ),
      ),
      onTap: () {
        showNotificationDialog(context, content, isRequest, color: color);
      },
    ));
  }

  showNotificationDialog(
      BuildContext context, NotificationsModel content, bool isRequest,
      {Color color}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: isRequest
                    ? Text(
                        "Request",
                        style: TextStyle(
                            color: shedAppBlue400, fontWeight: FontWeight.bold),
                      )
                    : Text("Announcement",
                        style: TextStyle(
                            color: shedAppBlue400,
                            fontWeight: FontWeight.bold)),
              ),
              body: SafeArea(
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        isRequest
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          "${content.requestType}",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16.0),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              height: 12.0,
                                              width: 12.0,
                                              decoration: BoxDecoration(
                                                  color: color,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              20.0))),
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "${content.requestStatus}",
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    )
                                  ])
                            : SizedBox(),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                                "${DateFormat.yMMMEd().format(DateTime.parse(content.createdAt))}"),
                            isRequest
                                ? GestureDetector(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (_) {
                                        return UpdateNotificationPage(
                                          content: content,
                                          color: color,
                                        );
                                      }));
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.edit),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Text("Edit")
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Divider(),
                        SizedBox(
                          height: 10.0,
                        ),
                        Text("${content.message}"),
                        SizedBox(
                          height: 20.0,
                        ),
                        content.attachmentUrl != null
                            ? Column(children: <Widget>[
                                AccessService.supportedImagesExtensions
                                        .contains(AccessService.getfileExtension(
                                            content.attachmentUrl))
                                    ? Image.network(
                                        content.attachmentUrl,
                                        height: 300.0,
                                      )
                                    : FlatButton(
                                        onPressed: () {
                                          _launchURL(content.attachmentUrl);
                                        },
                                        child: Text("View attachment")),
                                SizedBox(
                                  height: 10.0,
                                )
                              ])
                            : SizedBox(),
                        isRequest
                            ? Text(content.lastUpdated == null
                                ? ""
                                : "Last updated ${DateFormat.yMMMEd().format(DateTime.parse(content.lastUpdated))}")
                            : SizedBox(),
                      ],
                    ),
                  ),
                ),
              ));
        });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Cannot launch file"),
        backgroundColor: Colors.red,
      ));
    }
  }
}
