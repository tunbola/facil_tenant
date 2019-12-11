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
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ));
            }
            return ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: res.data.length,
              itemExtent: 90.0,
              itemBuilder: (context, idx) {
                final eachContent = res.data[idx];
                return Card(
                  elevation: 1,
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: InkWell(
                    onTap: () {
                      String _name = eachContent.sender.othernames == null ? eachContent.sender.email : "${eachContent.sender.othernames}";
                      _navigationService.navigateTo(routes.MessagesByTitle, arg: {"id": eachContent.sender.id, "username": _name});
                    },
                    child: ListTile(
                      isThreeLine: true,
                      leading: CircleAvatar(
                        backgroundColor: shedAppBlue100,
                        child: Text(eachContent.sender.othernames == null
                            ? "NN"
                            : "${eachContent.sender.surname[0].toUpperCase()}${eachContent.sender.othernames[0].toUpperCase()}"),
                        radius: 30,
                      ),
                      title: Text(eachContent.sender.othernames == null
                          ? "${eachContent.sender.email}"
                          : "${eachContent.sender.surname} ${eachContent.sender.othernames}"),
                      subtitle: Text(
                          "Title : ${AccessService.getLastContent(eachContent.title)} \n ${AccessService.getLastTime(eachContent.sentTimeGroup)}"),
                      trailing: AccessService.numberOfZeros(eachContent.isReadGroup) == 0 ? Text("") : Badge(
                        badgeContent: Text(
                          "${AccessService.numberOfZeros(eachContent.isReadGroup)}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        badgeColor: Colors.indigo,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return AppSpinner();
          }
        },
      ),
    );
  }
}
