import 'dart:async';

import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/chat_model.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:facil_tenant/components/app_scaffold.dart';

class ChatHistoryPage extends StatefulWidget {
  final Map<String, dynamic> routeParam;
  ChatHistoryPage(this.routeParam);

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState(this.routeParam);
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  final Map<String, dynamic> routeParam;

  HttpService _httpService = HttpService();
  String _userId = "";

  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();

  Duration interval = Duration(seconds: 1);
  ScrollController _scrollController = new ScrollController();

  List<String> _viewerIdList = [];
  int _counter = 0;

  final StreamController<int> _chatStreamController = StreamController<int>();
  List<ChatModel> _chatContent = [];

  _updateMessagesState(List<String> msgsIdList) {
    final msgIds = msgsIdList.reduce((value, element) => value + '|' + element);
    _httpService.updateMessagesState(msgIds);
  }

  Future<List<ChatModel>> _fetchChatFromDB() async {
    _userId = await AccessService.getUserId();
    List<ChatModel> _msgList = [];
    List<String> _msgIdsList = [];
    Map<String, dynamic> _response = await _httpService.fetchChatHistory(this.routeParam['senderId'], this.routeParam['title']);
    for (var i = 0; i < _response["data"].length; i++) {
      Map<String, dynamic> content = _response["data"][i];
      _msgIdsList.add(content["id"]);
      _msgList.add(ChatModel(
          id: content["id"],
          message: content["message"],
          createdAt: content["created_at"],
          from: content['added_by']));
      if (_viewerIdList.length < 1) {
        if (_userId != content['added_by'])
          _viewerIdList.add(content['added_by']);
      }
    }
    _updateMessagesState(_msgIdsList);
    return _msgList.reversed.toList();
  }

  Stream<List<ChatModel>> _chat() async* {
    _chatContent = await _fetchChatFromDB();
    yield await _chatContent;
  }

  bool _validateMsg(String content) {
    if (content.indexOf('|') != -1) return false;
    return true;
  }

  _ChatHistoryPageState(this.routeParam) {
    _chat().listen((content) {
      _counter = content.length;
      _chatStreamController.add(content.length);
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chatStreamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      pageTitle: ValueNotifier(
          "${routeParam['username'].toUpperCase()} (${routeParam['title']})"),
      child: StreamBuilder(
        stream: _chat(),
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                  child: Material(
                      child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(0.0),
                itemCount: res.data.length,
                reverse: true,
                shrinkWrap: true,
                itemBuilder: (context, idx) {
                  final eachContent = res.data[idx];
                  bool isFromMe = _userId == eachContent.from.toString();
                  Color _senderBoxColor = Colors.green[200];
                  Color _receipientBoxColor = Colors.blueAccent;
                  Future.delayed(Duration.zero, () {
                    _scrollController.animateTo(
                      0.0,
                      curve: Curves.easeOut,
                      duration: const Duration(milliseconds: 1000),
                    );
                  });

                  return Container(
                    margin: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 5.0,
                        ),
                        Align(
                            alignment: isFromMe
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft,
                            child: Container(
                              child: Text(
                                "${eachContent.message}",
                                style: TextStyle(
                                    color: isFromMe
                                        ? Colors.white
                                        : Colors.blueGrey),
                              ),
                              margin: isFromMe
                                  ? EdgeInsets.only(left: 50.0)
                                  : EdgeInsets.only(right: 50.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: isFromMe
                                          ? _receipientBoxColor
                                          : _senderBoxColor),
                                  borderRadius: BorderRadius.circular(15.0),
                                  color: isFromMe
                                      ? _receipientBoxColor
                                      : _senderBoxColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue[100],
                                      blurRadius:
                                          20.0, // has the effect of softening the shadow
                                      spreadRadius:
                                          5.0, // has the effect of extending the shadow
                                      offset: Offset(
                                        10.0, // horizontal, move right 10
                                        10.0, // vertical, move down 10
                                      ),
                                    )
                                  ]),
                            )),
                      ],
                    ),
                  );
                },
              ))),
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(10.0),
                child: Form(
                  key: _formKey,
                  child: new Table(
                    columnWidths: {
                      0: FlexColumnWidth(6),
                      1: FlexColumnWidth(3)
                    },
                    children: [
                      TableRow(children: [
                        TextFormField(
                          controller: _message,
                          decoration: InputDecoration(
                              hintText: "Message",
                              suffixIcon: IconButton(
                                icon: Icon(Icons.send),
                                color: shedAppBlue400,
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    if (_message.text.trim().length < 1) {
                                      return;
                                    }
                                    if (!_validateMsg(_message.text.trim())) {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("Message cannot contain |"),
                                        backgroundColor: Colors.red,
                                      ));
                                      return;
                                    }
                                    _httpService
                                        .sendMessage(
                                            _viewerIdList,
                                            routeParam['title'],
                                            _message.text.trim())
                                        .then((response) {
                                      _message.clear();
                                      setState(() {
                                        _counter += 1;
                                        _chatStreamController.add(_counter);
                                      });
                                    }).catchError((error) {
                                      Scaffold.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text("Failed..."),
                                        backgroundColor: Colors.red,
                                      ));
                                    });
                                  }
                                },
                              )),
                          maxLines: null,
                          maxLength: 2000,
                        ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          );
          } else {
            return AppSpinner();
          }
        },
      ),
    );
  }
}
