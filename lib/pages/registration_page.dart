import "package:flutter/material.dart";
import '../styles/colors.dart';
import "../services/http_service.dart";
import "package:facil_tenant/components/auth_button_spinner.dart";
import "package:facil_tenant/services/access_service.dart";
import "dart:async";

class RegistrationPage extends StatefulWidget {
  final Function presentSnack;
  RegistrationPage(this.presentSnack);

  @override
  RegistrationPageState createState() =>
      RegistrationPageState(this.presentSnack);
}

class RegistrationPageState extends State<RegistrationPage> {
  final Function presentSnack;

  final ValueNotifier _obscurePass = ValueNotifier(true);
  final ValueNotifier _obscurePassConf = ValueNotifier(true);

  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final passwordRetype = TextEditingController();
  final smsCode = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool buttonClicked = false;

  RegistrationPageState(
    this.presentSnack,
  );

  String _emailValidator(String email) {
    if (email.trim().length < 1) return "Email is required";
    if (AccessService.isValidEmail(email)) return null;
    return "Email address is invalid";
  }

  String _passwordValidator(String password, String retypePassword) {
    if (retypePassword.trim().length < 1) return "Please retype password";
    if (password.trim() != retypePassword.trim())
      return "Passwords are not the same";
    return null;
  }

  String _smsCodeValidator(String smsCode) {
    if (smsCode.trim().length < 1) return "Please enter your unique code";
    if (!AccessService.isValidCode(smsCode))
      return "Code should contain numbers only with length of 6";
    return null;
  }

  String _phoneNumberValidator(String phone) {
    if (phone.trim().length < 1) return "Please enter phone number";
    if (!AccessService.isPhoneNumber(phone))
      return "Phone number should contain numbers only of 11 or less";
    return null;
  }

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
                return Form(
                  key: _formKey,
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TextFormField(
                        controller: phone,
                        validator: (value) {
                          return _phoneNumberValidator(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Phone number',
                        ),
                        keyboardType: TextInputType.phone,
                        autocorrect: false,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      TextFormField(
                        controller: email,
                        validator: (value) {
                          return _emailValidator(value);
                        },
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
                          return TextFormField(
                            controller: password,
                            validator: (value) {
                              var val = value.isEmpty
                                  ? "Please enter password"
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
                        height: 10.0,
                      ),
                      ValueListenableBuilder(
                        valueListenable: _obscurePassConf,
                        builder: (context, val, child) {
                          return TextFormField(
                            controller: passwordRetype,
                            validator: (value) {
                              return _passwordValidator(value, password.text);
                            },
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
                      TextFormField(
                        controller: smsCode,
                        validator: (value) {
                          return _smsCodeValidator(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Secret Code',
                        ),
                        autocorrect: false,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                        child: buttonClicked
                            ? SizedBox(
                                child: AuthButtonSpinner(Colors.white),
                                height: 20.0,
                                width: 20.0,
                              )
                            : Text('REGISTER'),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            setState(() {
                              buttonClicked = true;
                            });
                            HttpService httpService = new HttpService();
                            Future response = httpService.registerUser(
                                phone.text.trim(),
                                email.text.trim(),
                                password.text.trim(),
                                smsCode.text.trim());
                            response.then((response) {
                              if (response != null) {
                                setState(() {
                                  buttonClicked = false;
                                });
                                if (response["status"]) {
                                  String message =
                                      "${response['message']}... Please log in.";
                                  presentSnack(context, message, Colors.green,
                                      Colors.white);
                                  Future.delayed(
                                      Duration(seconds: 2),
                                      () => Navigator.of(context)
                                          .pushNamed("login/signin"));
                                } else {
                                  presentSnack(context, response["message"],
                                      Colors.red, Colors.white);
                                }
                              }
                            });
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Already have an account?",
                            ),
                            FlatButton(
                              child: Text(
                                "login",
                                style: Theme.of(context)
                                    .textTheme
                                    .display1
                                    .copyWith(
                                      fontSize: 14.0,
                                    ),
                              ),
                              onPressed: () => Navigator.of(context)
                                  .pushNamed("login/signin"),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
