import 'dart:async';
import 'package:facil_tenant/services/access_service.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import "package:facil_tenant/routes/route_paths.dart" as routes;

class SplashPage extends StatelessWidget {
  SplashPage();

  _checkAuthState(BuildContext context) async {
    final isReturningUser = await LocalStorage.getItem("oldUser");
    if (isReturningUser == false) {
      await LocalStorage.setItem("oldUser", "yes");
      Navigator.of(context).pushReplacementNamed('onboarding');
    } else {
      var _route = await AccessService.getLastVisitedRoute();
      if (_route != null) {
        //user has used the application before because this
        //_navigationService handler is used to register routes
        //only after the user has logged in
        //_navigationService.navigateTo(_route);
        Navigator.of(context).pushReplacementNamed(routes.Home);
        return;
      }
      Navigator.of(context).pushReplacementNamed('auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () => _checkAuthState(context));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "FACIL",
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontSize: 100.0),
                textAlign: TextAlign.center,
              ),
              Text(
                "The Real Estate Manager",
                style: Theme.of(context)
                    .textTheme
                    .subtitle2
                    .copyWith(fontSize: 20.0),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }
}
