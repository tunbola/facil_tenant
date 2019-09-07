import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SplashPage extends StatelessWidget {
  const SplashPage();

  _checkAuthState(BuildContext context) async {
    final isReturningUser = await LocalStorage.getItem("oldUser");
    if (isReturningUser == false) {
      await LocalStorage.setItem("oldUser", true);
      Navigator.of(context).pushReplacementNamed('onboarding');
    } else {
      final isLoggedIn = await LocalStorage.getItem("isLoggedIn");
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('auth');
      } else {
        Navigator.of(context).pushReplacementNamed('auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 2), () => _checkAuthState(context));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("FACIL", style: Theme.of(context).textTheme.headline.copyWith(fontSize: 100.0), textAlign: TextAlign.center,),
              Text("The Real Estate Manager", style: Theme.of(context).textTheme.subtitle.copyWith(fontSize: 20.0), textAlign: TextAlign.center,)
            ],
          ),
        ),
      ),
    );
  }
}
