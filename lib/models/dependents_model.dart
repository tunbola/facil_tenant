import 'package:flutter/material.dart';

class DependentsModel {
  int id;
  String title;

  DependentsModel({@required this.id, @required this.title});

  factory DependentsModel.fromJson(Map<String, dynamic> json) {
    return DependentsModel(id: json['id'], title: json['title']);
  }
}