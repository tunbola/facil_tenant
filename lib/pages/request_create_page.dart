import 'dart:convert';

import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/services/http_service.dart';
import 'package:facil_tenant/styles/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:facil_tenant/components/app_scaffold.dart';
import 'package:facil_tenant/components/app_spinner.dart';
import "package:facil_tenant/components/auth_button_spinner.dart";

class RequestsPage extends StatefulWidget {
  @override
  _RequesetState createState() => _RequesetState();
}

class _RequesetState extends State<RequestsPage> {
  HttpService _httpService = HttpService();

  final _formKey = GlobalKey<FormState>();
  final _request = TextEditingController();
  final ValueNotifier _requestType = ValueNotifier(null);
  String encodedAttachment = "";
  bool _buttonClicked = false;
  String attachmentName = "";
  Map<String, dynamic> response = {"status": false, "message": ""};

  Future<Map<String, dynamic>> _getRequestTypes() async {
    Map<String, dynamic> response = await _httpService.fetchRequestTypes();
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getRequestTypes(),
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
            return AppScaffold(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${response['message']}",
                        style: TextStyle(
                            color: response['status']
                                ? Colors.green
                                : Colors.redAccent,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Form(
                          child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            height: 50.0,
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0)),
                              border: Border.all(color: shedAppBlue400),
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: _requestType,
                              builder: (context, type, child) {
                                List _requestTypes = res.data["data"];
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    value: type,
                                    hint: Text("Request Type"),
                                    items: _requestTypes.map((item) {
                                      return DropdownMenuItem(
                                          child: Text(item["name"]),
                                          value: item["id"].toString());
                                    }).toList(),
                                    onChanged: (val) {
                                      _requestType.value = val;
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          TextFormField(
                            controller: _request,
                            decoration: InputDecoration(hintText: "Request"),
                            maxLines: null,
                            maxLength: 2000,
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                child: GestureDetector(
                                  onTap: () async {
                                    final file = await FilePicker.getFile(
                                        type: FileType.ANY);
                                    if (file == null) return;
                                    setState(() {
                                      attachmentName = "Please wait ...";
                                    });
                                    List splitPath = file.path.split('/');
                                    String fileName =
                                        splitPath[splitPath.length - 1];
                                    List splitName = fileName.split(".");
                                    String fileExt =
                                        splitName[splitName.length - 1];
                                    if (AccessService.supportedExtensions
                                        .contains(fileExt)) {
                                      setState(() {
                                        attachmentName = fileName;
                                        response['message'] = "";
                                      });
                                      var attachment = file.readAsBytesSync();
                                      encodedAttachment =
                                          base64Encode(attachment);
                                      return;
                                    }
                                    setState(() {
                                      response = {
                                        "message":
                                            "File has to be an image or pdf",
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
                              ))
                        ],
                      ))
                    ],
                  ),
                ),
              ),
              pageTitle: ValueNotifier("CREATE NEW REQUEST"),
              bottomWidget: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                child: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        if (_requestType.value == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please choose a request type'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }
                        if (_request.text.trim().length < 1) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Please fill in your request'),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }
                        setState(() {
                          _buttonClicked = true;
                        });
                        Map<String, dynamic> cr = encodedAttachment.length > 1
                            ? await _httpService.createRequest(
                                _requestType.value, _request.text.trim(),
                                attachment: encodedAttachment)
                            : await _httpService.createRequest(
                                _requestType.value, _request.text.trim());
                        if (cr['status']) {
                          setState(() {
                            _buttonClicked = false;
                            encodedAttachment = "";
                            attachmentName = "";
                            _request.text = "";
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("${cr['message']}"),
                            backgroundColor: Colors.green,
                          ));
                          return;
                        }
                        setState(() {
                          _buttonClicked = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("Error while sending your request"),
                          backgroundColor: Colors.red,
                        ));
                        return;
                      },
                      child: _buttonClicked
                          ? SizedBox(
                              child: AuthButtonSpinner(Colors.white),
                              height: 20.0,
                              width: 20.0,
                            )
                          : Text("Send request"),
                    );
                  },
                ),
              ),
            );
          } else {
            return AppScaffold(
                pageTitle: ValueNotifier(""), child: AppSpinner());
          }
        });
  }
}
