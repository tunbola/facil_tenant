import 'package:flutter/material.dart';

import '../components/app_scaffold.dart';

import '../styles/colors.dart';

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
                return LoginPage(
                  presentSnack,
                  goHome,
                );
              });
              break;
            case 'login/signup':
              pageTitle("register");
              return MaterialPageRoute(builder: (
                BuildContext context,
              ) {
                return RegistrationPage(
                  presentSnack,
                  goHome,
                );
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
                    goHome,
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

class RegistrationPage extends StatelessWidget {
  final Function presentSnack;
  final Function goHome;
  final ValueNotifier _obscurePass = ValueNotifier(true);
  final ValueNotifier _obscurePassConf = ValueNotifier(true);

  RegistrationPage(
    this.presentSnack,
    this.goHome,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Center(
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
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _obscurePass,
                      builder: (context, val, child) {
                        return TextField(
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
                      height: 10.0,
                    ),
                    ValueListenableBuilder(
                      valueListenable: _obscurePassConf,
                      builder: (context, val, child) {
                        return TextField(
                          decoration: InputDecoration(
                            hintText: 'Password Confirm',
                            suffixIcon: GestureDetector(
                              child: Icon(
                                _obscurePass.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: shedAppBlue400,
                              ),
                              onTap: () => _obscurePassConf.value =
                                  !_obscurePassConf.value,
                            ),
                          ),
                          autocorrect: false,
                          obscureText: val,
                        );
                      },
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Secret Code',
                      ),
                      autocorrect: false,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    RaisedButton(
                      child: Text('REGISTER'),
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Already have an account?",
                          ),
                          FlatButton(
                            child: Text(
                              "login",
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
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final Function presentSnack;
  final Function goHome;
  final ValueNotifier _obscurePass = ValueNotifier(true);
  // final ValueNotifier _accType = ValueNotifier(null);

  LoginPage(
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
                  // ValueListenableBuilder(
                  //   valueListenable: _accType,
                  //   builder: (context, val, child) {
                  //     return DropdownButtonFormField(
                  //       decoration: InputDecoration(
                  //         labelStyle:
                  //             Theme.of(context).inputDecorationTheme.labelStyle,
                  //         enabledBorder: Theme.of(context)
                  //             .inputDecorationTheme
                  //             .enabledBorder,
                  //         focusedBorder: Theme.of(context)
                  //             .inputDecorationTheme
                  //             .enabledBorder,
                  //       ),
                  //       hint: Text("Select Account Type"),
                  //       value: val,
                  //       items: <String>["Facility Manager", "Tenant"]
                  //           .map((it) =>
                  //               DropdownMenuItem(value: it, child: Text(it)))
                  //           .toList(),
                  //       onChanged: (valu) => _accType.value = valu,
                  //     );
                  //   },
                  // ),
                  // SizedBox(
                  //   height: 10.0,
                  // ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Email',
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
                      return TextField(
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
                    child: Text('LOGIN'),
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
              );
            },
          ),
        ),
      ),
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
