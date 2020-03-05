import 'dart:convert';

import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/auth_button_spinner.dart';
import 'package:facil_tenant/models/index.dart';
import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class UpdateNotificationPage extends StatefulWidget {
  final Color color;
  final NotificationsModel content;

  UpdateNotificationPage({this.color, this.content});

  @override
  _UpdateNotificationPageState createState() => _UpdateNotificationPageState();
}

class _UpdateNotificationPageState extends State<UpdateNotificationPage> {
  TextEditingController message;
  bool buttonClicked = false;
  String attachmentName = "";
  String encodedAttachment = "";
  Map<String, dynamic> response = {"status": false, "message": ""};

  HttpService _httpService = HttpService();

  @override
  void initState() {
    super.initState();
    message = TextEditingController(text: widget.content.message);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      pageTitle: ValueNotifier("UPDATE REQUEST"),
      child: Container(
        height: MediaQuery.of(context).size.height * 75,
        width: MediaQuery.of(context).size.width * 80,
        margin: EdgeInsets.all(10.0),
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            color: Colors.white),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 20.0,
              ),
              Text(
                "${response['message']}",
                style: TextStyle(
                    color: response['status'] ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: 50.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(color: shedAppBlue400)),
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.0, left: 10.0),
                        child: Text(
                          "${widget.content.requestType}",
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      controller: message,
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          child: GestureDetector(
                            onTap: () async {
                              final file = await FilePicker.getFile(type: FileType.ANY);
                              if (file == null) return;
                              setState(() {
                                attachmentName = "Please wait ...";
                              });
                              List splitPath = file.path.split('/');
                              String fileName = splitPath[splitPath.length - 1];
                              List splitName = fileName.split(".");
                              String fileExt = splitName[splitName.length - 1];
                              if (AccessService.supportedExtensions.contains(fileExt)) {
                                setState(() {
                                  attachmentName = fileName;
                                  response['message'] = "";
                                });
                                var attachment = file.readAsBytesSync();
                                encodedAttachment = base64Encode(attachment);
                                return;
                              }
                              setState(() {
                                response = {
                                  "message": "File has to be an image or pdf",
                                  "status": false
                                };
                                attachmentName = "";
                                encodedAttachment = "";
                              });
                              return;
                            },
                            child: Row(
                              //mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Expanded(
                                  child: Text("$attachmentName"),
                                ),
                                Icon(Icons.attach_file),
                                Text("Attach file")
                              ],
                            ),
                          ),
                        )),
                    SizedBox(
                      height: 15.0,
                    ),
                    RaisedButton(
                      child: buttonClicked
                          ? AuthButtonSpinner(Colors.white)
                          : Text("Update"),
                      onPressed: () async {
                        if (message.text.trim().length < 1) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Please fill in your request'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }
                        setState(() {
                          buttonClicked = true;
                          response['message'] = "";
                        });
                        Map<String, dynamic> cr = encodedAttachment.length > 1
                            ? await _httpService.updateRequest(
                                widget.content.id, message.text.trim(),
                                attachment: encodedAttachment)
                            : await _httpService.updateRequest(
                                widget.content.id, message.text.trim());
                        if (cr['status']) {
                          setState(() {
                            buttonClicked = false;
                            encodedAttachment = "";
                            response = {"status": true, "message": "${cr['message']}"};
                          });
                          return;
                        }
                        setState(() {
                          buttonClicked = false;
                          response = {"status": false, "message": "${cr['message']}"};
                        });
                        return;
                      },
                    )
                  ]),
            ],
          ),
        ),
      ),
    );
  }
}
