import 'dart:math';

import 'package:flutter/material.dart';

class Item {
  String _id;
  String name;
  double price;

  bool isSelected;
  Color? selectedColour;

  Item({required this.name, required this.price, required this.isSelected})
      : _id = _generateUniqueId();

  static String _generateUniqueId() {
    // Combine current time with random value to ensure uniqueness
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomValue = Random().nextInt(10000); // Adding some randomness
    return '$timestamp-$randomValue';
  }

  // Factory constructor to create an Item from JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      isSelected: false,
    );
  }
}

List<Item> extractItems(String extractedPdfText) {
  List<Item> items = [];

  // Regular expression to match item names and prices
  // This is a basic regex, adjust it to your receipt format
  // RegExp itemRegExp = RegExp(r"([A-Za-z\s]+)\s+\$?(\d+\.\d{2})");
  RegExp itemRegExp = RegExp(r"([A-Za-z0-9\s^#&\-,]+)\s+(\-?\d+\.\d{2})");

  // Split the extracted text into lines and iterate through each line
  var lines = extractedPdfText.split('\n');
  for (var line in lines) {
    var match = itemRegExp.firstMatch(line);

    if (match != null) {
      String itemName = match.group(1)!.trim();
      double itemPrice = double.tryParse(match.group(2)!) ?? 0.0;

      if (itemPrice != 0.0) {
        items.add(Item(name: itemName, price: itemPrice, isSelected: false));
      }
    }
  }
  return items;
}
