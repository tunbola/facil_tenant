import 'package:flutter/material.dart';
import 'package:facil_tenant/components/app_scaffold.dart';

class NotificationCreatePage extends StatelessWidget {
  final ValueNotifier _type = ValueNotifier(null);
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Form(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ValueListenableBuilder(
                valueListenable: _type,
                builder: (context, type, child) {
                  return DropdownButtonFormField(
                    value: type,
                    hint: Text("Message Type"),
                    items: [
                      DropdownMenuItem(
                        value: "Repair Request",
                        child: Text("Repair"),
                      ),
                      DropdownMenuItem(
                        value: "Complaint",
                        child: Text("Complaint"),
                      ),
                      DropdownMenuItem(
                        value: "General Request",
                        child: Text("Request"),
                      ),
                    ],
                    onChanged: (val) {
                      _type.value = val;
                    },
                  );
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Title"),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Body"),
                maxLines: null,
                maxLength: 2000,
              ),
            ],
          ),
        ),
      ),
      pageTitle: ValueNotifier("MESSAGE CREATION"),
      bottomWidget: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 10.0,
        ),
        child: RaisedButton(
          onPressed: () => "",
          child: ValueListenableBuilder(
            valueListenable: _type,
            builder: (context, type, child) {
              return Text("Send ${type ?? 'Message'}");
            },
          ),
        ),
      ),
    );
  }
}
