import 'package:facil_tenant/services/http_service.dart';
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
  bool _buttonClicked = false;

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
                      Form(
                          child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          ValueListenableBuilder(
                            valueListenable: _requestType,
                            builder: (context, type, child) {
                              List _requestTypes = res.data["data"];
                              return DropdownButtonFormField(
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
                              );
                            },
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
                    return RaisedButton(
                      onPressed: () {
                        if (_requestType.value == null) {
                          return Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Please choose a request type'),
                            backgroundColor: Colors.red,
                          ));
                        }
                        if (_request.text.trim().length < 1) {
                          return Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Please fill in your request'),
                            backgroundColor: Colors.red,
                          ));
                        }
                        setState(() {
                          _buttonClicked = true;
                        });
                        _httpService
                            .createRequest(
                                _requestType.value, _request.text.trim())
                            .then((response) {
                          setState(() {
                            _buttonClicked = false;
                          });
                          return Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("${response['message']}"),
                            backgroundColor:
                                response["status"] ? Colors.green : Colors.red,
                          ));
                        }).catchError((error) {
                          setState(() {
                            _buttonClicked = false;
                          });
                          return Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text("Error while sending your request"),
                            backgroundColor: Colors.red,
                          ));
                        });
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
