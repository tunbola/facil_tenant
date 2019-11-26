import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthButtonSpinner extends StatelessWidget {
  final Color color;

  const AuthButtonSpinner(this.color);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Platform.isIOS
          ? SizedBox(child: CupertinoActivityIndicator())
          : SizedBox(
              child: CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white)),
              height: 20.0,
              width: 20.0,
            ),
    );
  }
}
