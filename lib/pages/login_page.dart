import 'dart:convert';

import 'package:facil_tenant/services/access_service.dart';
import 'package:facil_tenant/services/navigation_service.dart';
import 'package:facil_tenant/singleton/locator.dart';
import 'package:flutter/material.dart';
import '../styles/colors.dart';
import "../services/http_service.dart";
import "package:facil_tenant/components/auth_button_spinner.dart";
import "package:facil_tenant/routes/route_paths.dart" as routes;

class LoginPage extends StatefulWidget {
  final Function presentSnack;  //snack bar for all pages connected to authentication

  LoginPage(this.presentSnack);

  @override
  LoginFormState createState() => LoginFormState(this.presentSnack);
}

class LoginFormState extends State<LoginPage> {

  final Function presentSnack;
  LoginFormState(this.presentSnack); //snackbar is meant to display messages to users on authentication pages based on context

  final ValueNotifier _obscurePass = ValueNotifier(true); //toggle between showing password and hiding password in input field
  
  final username = TextEditingController();
  final password = TextEditingController();

  NavigationService _navigationService = locator<NavigationService>();
  
  final _formKey = GlobalKey<FormState>();
  bool buttonClicked = false;

  Future<void> getLoginInfo() async {
    Map<String, dynamic> response = await AccessService.getLoginInfo();
    if (response != null) {
      username.text = response['username'];
      password.text = response['password'];
    }
  }

  @override
  void initState() {
    super.initState();
    getLoginInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 16.0,
        ),
        child: Container(
          child: Form(
                key: _formKey,
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: username,
                      validator: (value) {
                        var val = value.isEmpty
                            ? "Please enter your email address or phone number "
                            : null;
                        return val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Email or phone number',
                      ),
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _obscurePass,
                      builder: (context, val, child) {
                        return TextFormField(
                          controller: password,
                          validator: (value) {
                            var val = value.isEmpty
                                ? "Please enter your password "
                                : null;
                            return val;
                          },
                          decoration: InputDecoration(
                            hintText: 'Password',
                            suffixIcon: GestureDetector(
                              child: Icon(
                                _obscurePass.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: shedAppBlue400,
                              ),
                              onTap: () =>
                                  _obscurePass.value = !_obscurePass.value,
                            ),
                          ),
                          autocorrect: false,
                          obscureText: val,
                        );
                      },
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      child: buttonClicked
                          ? SizedBox(
                              child: AuthButtonSpinner(Colors.white),
                              height: 20.0,
                              width: 20.0,
                            )
                          : Text('LOGIN'),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            buttonClicked = true;
                          });
                          HttpService httpService = new HttpService();
                          Map<String, dynamic> response = await httpService.userLogin(username.text.trim(), password.text.trim());
                          //save access token and other information
                          setState(() {
                            buttonClicked = false;
                          });
                          if (response['status']) {
                            bool access = await AccessService.setAccess(json.encode(response['data']));
                            await AccessService.saveLogin(json.encode({"username": username.text.trim(), "password": password.text.trim()}));
                            if (access) {
                              _navigationService.navigateTo(routes.Home);
                              return;
                            }
                          }
                          presentSnack(context, response['message'], Colors.redAccent, Colors.white);
                          return;
                        } 
                      },
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                "New here?",
                              ),
                              FlatButton(
                                child: Text(
                                  "register",
                                  style: Theme.of(context)
                                      .textTheme
                                      .display1
                                      .copyWith(
                                        fontSize: 14.0,
                                      ),
                                ),
                                onPressed: () => Navigator.of(context)
                                    .pushNamed("login/signup"),
                              ),
                            ],
                          ),
                          FlatButton(
                            child: Text(
                              "Retrieve Password",
                              textAlign: TextAlign.right,
                              style:
                                  Theme.of(context).textTheme.display1.copyWith(
                                        fontSize: 14.0,
                                      ),
                            ),
                            onPressed: () => Navigator.of(context)
                                .pushNamed("login/retrievepass"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )

        ),
      ),
    );
  }
}
