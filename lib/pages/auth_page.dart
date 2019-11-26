import 'package:flutter/material.dart';

import '../components/app_scaffold.dart';
import '../styles/colors.dart';
import "package:facil_tenant/pages/registration_page.dart";

import "package:facil_tenant/pages/login_page.dart";

BuildContext ctx;

class AuthPage extends StatelessWidget {
  final _pgTitle = ValueNotifier("LOGIN");

  presentSnack(
    BuildContext context,
    String content,
    Color bgCol,
    Color txtCol,
  ) {
    Scaffold.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Text(content),
        backgroundColor: bgCol,
        action: SnackBarAction(
          textColor: txtCol,
          label: "OK",
          onPressed: () {},
        ),
      ),
    );
  }

  pageTitle(String title) {
    _pgTitle.value = title.toUpperCase();
  }

  goHome() {
    Navigator.of(ctx).pushReplacementNamed('home');
  }

  @override
  Widget build(BuildContext context) {
    ctx = context;
    return AppScaffold(
      child: Navigator(
        initialRoute: 'login/signin',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case 'login/signin':
              pageTitle("login");
              return MaterialPageRoute(builder: (
                BuildContext context,
              ) {
                return LoginPage(presentSnack);
              });
              break;
            case 'login/signup':
              pageTitle("register");
              return MaterialPageRoute(builder: (
                BuildContext context,
              ) {
                return RegistrationPage(presentSnack);
              });
              break;
            case 'login/retrievepass':
              pageTitle("Retrieve Password");
              return MaterialPageRoute(builder: (
                BuildContext context,
              ) {
                return ForgotPasswordPage(
                  presentSnack,
                  goHome,
                );
              });
              break;
            default:
              pageTitle("login");
              return MaterialPageRoute(
                builder: (BuildContext context) {
                  return LoginPage(
                    presentSnack,
                  );
                },
              );
          }
        },
      ),
      pageTitle: _pgTitle,
    );
  }
}

class ForgotPasswordPage extends StatelessWidget {
  final Function presentSnack;
  final Function goHome;

  ForgotPasswordPage(
    this.presentSnack,
    this.goHome,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 16.0,
        ),
        child: Container(
          child: Builder(
            builder: (BuildContext context) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
                    ),
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  RaisedButton(
                    child: Text('SUBMIT'),
                    onPressed: () => goHome(),
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
                            "Back to login",
                            textAlign: TextAlign.right,
                            style:
                                Theme.of(context).textTheme.display1.copyWith(
                                      fontSize: 14.0,
                                    ),
                          ),
                          onPressed: () =>
                              Navigator.of(context).pushNamed("login/signin"),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
