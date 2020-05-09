import 'package:badges/badges.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/messages_by_title_model.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/services/navigation_service.dart';
import 'package:facil_tenant/singleton/locator.dart';
import 'package:facil_tenant/routes/route_paths.dart' as routes;
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';

class MessagesByTitlePage extends StatefulWidget {
  final Map<String, dynamic> argument;
  MessagesByTitlePage(this.argument);
  @override
  _MessagesByTitleState createState() => _MessagesByTitleState(argument);
}

class _MessagesByTitleState extends State<MessagesByTitlePage> {
  Map<String, dynamic> routeParam;
  _MessagesByTitleState(this.routeParam);

  HttpService _httpService = HttpService();
  NavigationService _navigationService = locator<NavigationService>();
  AccessService accessService = AccessService();

  Future<List<MessagesByTitleModel>> _getMessagesByTitle() async {
    List<MessagesByTitleModel> _myList = [];
    Map<String, dynamic> _response =
        await _httpService.fetchMessagesByTitle(routeParam['id'].toString());

    for (var i = 0; i < _response["data"].length; i++) {
      Map<String, dynamic> content = _response["data"][i];
      _myList.add(MessagesByTitleModel(
          id: content["id"],
          title: content["title"],
          messagesGroup: content["msg"],
          rowIdsGroup: content["row_ids"],
          isReadGroup: content["is_read"],
          sentTimeGroup: content["sent_time"]));
    }
    return Future.value(_myList);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
        pageTitle:
            ValueNotifier("${routeParam['username'].toUpperCase()}'S THREAD"),
        child: Container(
            padding: EdgeInsets.only(
              top: 10.0,
              left: 16.0,
              right: 16.0,
            ),
            child: FutureBuilder(
              future: _getMessagesByTitle(),
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
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 50.0,
                            ),
                            Text("No messages!",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ));
                  }
                  return ListView.separated(
                    itemCount: res.data.length,
                    itemBuilder: (context, idx) {
                      final eachContent = res.data[idx];
                      return Container(
                        padding: EdgeInsets.all(10.0),
                        child: InkWell(
                            onTap: () {
                              Map<String, dynamic> _arg = {
                                "msgsId": eachContent.rowIdsGroup,
                                "senderId": this.routeParam['id'],
                                "title": eachContent.title,
                                "username": this.routeParam["username"]
                              };
                              _navigationService.navigateTo(routes.ChatHistory,
                                  arg: _arg);
                            },
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                      Text(
                                        "${eachContent.title}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 5.0),
                                      AccessService.getLastContent(
                                                      eachContent.messagesGroup)
                                                  .length >
                                              150
                                          ? Text(
                                              "${AccessService.getLastContent(eachContent.messagesGroup).substring(0, 150)}...")
                                          : Text(
                                              "${AccessService.getLastContent(eachContent.messagesGroup)}"),
                                    ])),
                                SizedBox(
                                  width: 30.0,
                                  child: FutureBuilder(
                                      future: this.accessService.numberOfZeros(
                                          eachContent.isReadGroup),
                                      builder:
                                          (BuildContext context, snapshot) {
                                        if (snapshot.hasError)
                                          return SizedBox();
                                        if (!snapshot.hasData)
                                          return SizedBox();
                                        return snapshot.data == 0
                                            ? SizedBox()
                                            : Badge(
                                                badgeContent: Text(
                                                  "${snapshot.data}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                                ),
                                                badgeColor: Colors.redAccent,
                                              );
                                      }),
                                )
                              ],
                            )),
                      );
                    },
                    separatorBuilder: (context, idx) => Container(
                      height: 0.5,
                      color: Colors.grey,
                    ),
                  );
                } else {
                  return AppSpinner();
                }
              },
            )));
  }
}
