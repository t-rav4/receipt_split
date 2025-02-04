import 'package:flutter/material.dart';
import 'package:receipt_split/receipt_split_page.dart';

class User {
  String name;
  Color colour;

  List<Item> assignedItems = [];

  User({required this.name, required this.colour});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json["name"] as String,
      colour: Color(int.parse(json['colour'], radix: 16)),
    );
  }

  Map<String, dynamic> toJSON() {
    // ignore: deprecated_member_use
    return {"name": name, "colour": colour.value.toRadixString(16).padLeft(8, '0')};
  }

  void addItem(Item item) {
    assignedItems.add(item);
  }

}
