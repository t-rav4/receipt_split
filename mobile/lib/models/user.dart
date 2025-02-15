import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';

class User {
  String id;
  String name;
  Color colour;

  List<Item> assignedItems = [];

  User({required this.id, required this.name, required this.colour});

  factory User.fromJson(Map<String, dynamic> json) {
    // Check if fields are null or missing and provide default values if necessary
    return User(
      id: json["id"],
      name: json["name"] as String? ?? 'Unknown', // Provide a default if null
      colour: Color(int.tryParse(json['colour'] ?? 'FFFFFFFF', radix: 16) ??
          0xFFFFFFFF), // Handle null for colour
    );
  }
  Map<String, dynamic> toJSON() {
    // ignore: deprecated_member_use
    return {
      "id": id,
      "name": name,
      "colour": colour.value.toRadixString(16).padLeft(8, '0')
    };
  }

  void addItem(Item item) {
    assignedItems.add(item);
  }

  User copyWith({
    String? name,
    Color? colour,
    List<Item>? assignedItems,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      colour: colour ?? this.colour,
    )..assignedItems = assignedItems ?? this.assignedItems;
  }

  // Overriding toString method for better object representation
  @override
  String toString() {
    return 'User(name: $name, colour: $colour, id: $id)';
  }
}
