import 'package:cached_network_image/cached_network_image.dart';
import 'package:facil_tenant/models/received_messages_model.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/user_model.dart';
import 'package:badges/badges.dart';
import "package:facil_tenant/services/navigation_service.dart";
import "package:facil_tenant/singleton/locator.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;
import "package:facil_tenant/services/access_service.dart";

class MessagesPage extends StatefulWidget {
  @override
  _MessageListBySenders createState() => _MessageListBySenders();
}

class _MessageListBySenders extends State<MessagesPage> {
  final _httpService = new HttpService();
  NavigationService _navigationService = locator<NavigationService>();
  AccessService accessService = AccessService();

  Future<List<ReceivedMessagesModel>> _getMessages() async {
    Map<String, dynamic> response = await _httpService.fetchMessageSenders();
    List<ReceivedMessagesModel> _myList = [];

    for (var i = 0; i < response["data"].length; i++) {
      Map<String, dynamic> content = response["data"][i];
      _myList.add(ReceivedMessagesModel(
          id: content["id"],
          title: content["msg_title"],
          messagesGroup: content["row_ids"],
          sender: UserModel.fromJson(content["addedBy"]),
          isReadGroup: content["is_read"],
          sentTimeGroup: content["sent_time"]));
    }
    return Future.value(_myList);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      pageTitle: ValueNotifier("MESSAGES"),
      child: Container(
          padding: EdgeInsets.only(
            top: 10.0,
            left: 16.0,
            right: 16.0,
          ),
          child: FutureBuilder(
            future: _getMessages(),
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
                    ReceivedMessagesModel eachContent = res.data[idx];
                    return Card(
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                          ),
                          child: InkWell(
                              onTap: () {
                                String _name =
                                    eachContent.sender.othernames == null
                                        ? eachContent.sender.email
                                        : "${eachContent.sender.othernames}";
                                _navigationService
                                    .navigateTo(routes.MessagesByTitle, arg: {
                                  "id": eachContent.sender.id,
                                  "username": _name
                                });
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                    child: eachContent.sender.pictureUrl == null
                                        ? CircleAvatar(
                                            radius: 30.0,
                                            backgroundColor: shedAppBlue100,
                                            child: Text(eachContent
                                                        .sender.othernames ==
                                                    null
                                                ? "NN"
                                                : "${eachContent.sender.surname[0].toUpperCase()}${eachContent.sender.othernames[0].toUpperCase()}"))
                                        : CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    eachContent
                                                        .sender.pictureUrl),
                                            radius: 30.0,
                                          ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                        eachContent.sender.othernames == null
                                            ? Text(
                                                "${eachContent.sender.email}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )
                                            : Text(
                                                "${eachContent.sender.surname} ${eachContent.sender.othernames}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                        SizedBox(height: 5.0),
                                        Text(
                                            "${AccessService.getLastContent(eachContent.title)}"),
                                      ])),
                                  SizedBox(
                                    width: 60.0,
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          "${AccessService.getLastTime(eachContent.sentTimeGroup)}",
                                          style: TextStyle(fontSize: 10.0),
                                        ),
                                        SizedBox(height: 5.0),
                                        FutureBuilder(
                                            future: this
                                                .accessService
                                                .numberOfZeros(
                                                    eachContent.isReadGroup),
                                            builder: (BuildContext context,
                                                snapshot) {
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
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      badgeColor:
                                                          shedAppBlue300,
                                                    );
                                            })
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ));
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
          )),
    );
  }
}
