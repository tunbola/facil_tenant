import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:facil_tenant/components/app_spinner.dart';
import 'package:facil_tenant/models/chat_model.dart';
import 'package:facil_tenant/pages/Image_viewer.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

_ChatHistoryPageState chatHistoryPage;

class ChatHistoryPage extends StatefulWidget {
  final Map<String, dynamic> routeParam;
  ChatHistoryPage(this.routeParam);

  @override
  _ChatHistoryPageState createState() {
    chatHistoryPage = _ChatHistoryPageState(this.routeParam);
    return chatHistoryPage;
  }
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

  int _indexToShow = 1;

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
    Map<String, dynamic> _response = await _httpService.fetchChatHistory(
        this.routeParam['senderId'], this.routeParam['title']);
    for (var i = 0; i < _response["data"].length; i++) {
      Map<String, dynamic> content = _response["data"][i];
      _msgIdsList.add(content["id"]);
      _msgList.add(ChatModel(
          id: content["id"],
          message: content["message"],
          createdAt: content["created_at"],
          attachmentUrl: content['attachment_url'],
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
    });
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
                    final ChatModel eachContent = res.data[idx];
                    bool isFromMe = _userId == eachContent.from.toString();

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
                          Container(
                              alignment: isFromMe
                                  ? Alignment.bottomRight
                                  : Alignment.bottomLeft,
                              child: isFromMe
                                  ? Dismissible(
                                      key: UniqueKey(),
                                      onDismissed: (direction) {
                                        _httpService
                                            .deleteMessages(eachContent.id)
                                            .then((response) {setState(() {});})
                                            .catchError((onError) {});
                                      },
                                      child: _chatBox(isFromMe, eachContent),
                                    )
                                  : _chatBox(isFromMe, eachContent)),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            alignment: isFromMe? Alignment.bottomRight : Alignment.bottomLeft,
                            child: Text("${DateFormat.yMMMEd().format(DateTime.parse(eachContent.createdAt))}", style: TextStyle(fontSize: 10.0, fontWeight: FontWeight.bold),),
                          )
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
                        0: FlexColumnWidth(8),
                        1: FlexColumnWidth(1)
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
                                          content:
                                              Text("Message cannot contain |"),
                                          backgroundColor: Colors.red,
                                        ));
                                        return;
                                      }
                                      _httpService
                                          .sendMessage(_viewerIdList,
                                              routeParam['title'],
                                              message: _message.text.trim())
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
                          IconButton(
                              icon: Icon(Icons.attach_file),
                              onPressed: () async {
                                final file = await FilePicker.getFile(
                                    type: FileType.ANY);
                                if (file == null) return;
                                List splitPath = file.path.split('/');
                                String fileName =
                                    splitPath[splitPath.length - 1];
                                List splitName = fileName.split(".");
                                String fileExt =
                                    splitName[splitName.length - 1];
                                if (!AccessService.supportedExtensions
                                    .contains(fileExt)) {
                                  //extension is not supported
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text("File type is not supported"),
                                    backgroundColor: Colors.red,
                                  ));
                                  return;
                                }
                                showAttachmentPreview(context, file, fileExt);
                              })
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

  showAttachmentPreview(BuildContext context, File file, String fileExt) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                  backgroundColor: shedAppBlue400,
                  onPressed: () {
                    var attachment = file.readAsBytesSync();
                    String encodedAttachment = base64Encode(attachment);
                    _httpService
                        .sendMessage(_viewerIdList, routeParam['title'],
                            attachment: encodedAttachment)
                        .then((response) {
                      chatHistoryPage.setState(() {
                        _counter += 1;
                        _chatStreamController.add(_counter);
                      });
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text("Failed..."),
                        backgroundColor: Colors.red,
                      ));
                    });
                  },
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  )),
              backgroundColor: Colors.grey[400],
              appBar: AppBar(
                  backgroundColor: shedAppBlue400,
                  title: Text(
                    "Preview",
                    style: TextStyle(color: Colors.white),
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )),
              body: SafeArea(
                  child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Container(
                    child: fileExt.toLowerCase() == 'pdf'
                        ? IndexedStack(index: _indexToShow, children: [
                            PDFView(
                              filePath: file.path,
                              autoSpacing: true,
                              enableSwipe: true,
                              pageSnap: true,
                              onError: (e) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text("${e.toString()}"),
                                ));
                              },
                              onRender: (_pages) {
                                setState(() {
                                  _indexToShow = 0;
                                });
                              },
                            ),
                            AppSpinner()
                          ])
                        : Image.file(
                            file,
                          )),
              )),
            );
          });
        });
  }

  Widget _chatBox(bool isFromMe, ChatModel eachContent) {
    Color _senderBoxColor = Colors.blue[50];
    Color _receipientBoxColor = Colors.blueAccent;
    return eachContent.attachmentUrl != null
        ? Container(
            child: AccessService.supportedImagesExtensions.contains(
                    AccessService.getfileExtension(eachContent.attachmentUrl))
                ? InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return ImageViewer(eachContent.attachmentUrl);
                      }));
                    },
                    child: Container(
                      height: 270,
                      width: 250,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(eachContent.attachmentUrl),
                        ),
                      ),
                    ))
                : InkWell(
                    child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${AccessService.getfileName(eachContent.attachmentUrl)}",
                              style: TextStyle(
                                  color: isFromMe ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5.0),
                            Icon(
                              Icons.picture_as_pdf,
                              color: Colors.white,
                            ),
                            Divider(),
                            Center(
                              child: Text(
                                "Open",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            )
                          ]),
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
                        color: isFromMe ? _receipientBoxColor : _senderBoxColor,
                      ),
                    ),
                    onTap: () {
                      _launchURL(eachContent.attachmentUrl);
                    },
                  ))
        : Container(
            child: Text(
              "${eachContent.message}",
              style: TextStyle(color: isFromMe ? Colors.white : Colors.black),
            ),
            margin: isFromMe
                ? EdgeInsets.only(left: 50.0)
                : EdgeInsets.only(right: 50.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              border: Border.all(
                  color: isFromMe ? _receipientBoxColor : _senderBoxColor),
              borderRadius: BorderRadius.circular(15.0),
              color: isFromMe ? _receipientBoxColor : _senderBoxColor,
            ),
          );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
