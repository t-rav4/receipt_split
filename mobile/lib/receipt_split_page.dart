import 'dart:math';

import 'package:flutter/material.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:receipt_split/split_summary_page.dart';
import 'package:receipt_split/types/user.dart';

class ReceiptSplitPage extends StatefulWidget {
  final List<User> users;
  final String pdf;

  const ReceiptSplitPage({super.key, required this.users, required this.pdf});

  @override
  State<ReceiptSplitPage> createState() => _ReceiptSplitPageState();
}

// TOOD: two items with same name are selected at same time

class _ReceiptSplitPageState extends State<ReceiptSplitPage> {
  User? selectedUser;

  var isExtractingText = false;
  String extractedText = "";

  List<Item> purchasedItems = [];

  Map<Item, User?> itemToUserRecord = {};

  Map<User, double> userCosts = {};
  double totalSharedCostSplitBetweenUsers = 0.0;
  double totalCost = 0.0;

  @override
  void initState() {
    extractTextFromPdf();

    super.initState();
  }

  Future<void> extractTextFromPdf() async {
    try {
      setState(() => isExtractingText = true);

      String text = await ReadPdfText.getPDFtext(widget.pdf);
      var items = extractItems(text);

      // Init the map for item to users to empty
      Map<Item, User?> emptyItemToUserMap = {
        for (var item in items) item: null
      };
      Map<User, double> emptyUserCostsMap = {
        for (var user in widget.users) user: 0.0
      };

      setState(() {
        purchasedItems = items;
        extractedText = text.isNotEmpty ? text : 'No text found in this PDF.';
        isExtractingText = false;
        itemToUserRecord = emptyItemToUserMap;
        userCosts = emptyUserCostsMap;
      });

      calculateSplitCosts();
    } catch (e) {
      setState(() {
        extractedText = 'Failed to extract text: $e';
      });
    }
  }

  void toggleItem(Item item) {
    if (selectedUser == null) {
      if (item.isSelected) {
        setState(() {
          item.selectedColour = Colors.transparent;
          item.isSelected = false;
          itemToUserRecord.remove(item);
        });
      }
      return;
    }

    // When selecting item with same assigned user, unassign them
    var userToAssign =
        itemToUserRecord[item] == selectedUser ? null : selectedUser;

    // If the item is selected/unselected - update the colour and the mapping
    Color newActiveColour = userToAssign?.colour ?? Colors.transparent;
    setState(() {
      item.selectedColour = newActiveColour;
      itemToUserRecord[item] = userToAssign;
      item.isSelected = userToAssign != null ? true : false;
    });

    calculateSplitCosts();
  }

  void calculateSplitCosts() {
    double totalSharedCost = 0.0;

    Map<User, double> userToCostMap = {
      for (var user in widget.users) user: 0.0
    };

    double totalItemsCost = 0.0;

    for (Item item in itemToUserRecord.keys) {
      totalItemsCost += item.price;

      var user = itemToUserRecord[item];

      if (user == null) {
        totalSharedCost += item.price;
        continue;
      }

      // Add item price to the assigned user
      userToCostMap[user] = userToCostMap[user]! + item.price;
    }

    var splitCost = totalSharedCost / userToCostMap.length;

    for (var user in userToCostMap.keys) {
      userToCostMap[user] = userToCostMap[user]! + splitCost;
    }

    setState(() {
      userCosts = userToCostMap;
      totalSharedCostSplitBetweenUsers = splitCost;
      totalCost = totalItemsCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: widget.users.map(
                  (user) {
                    return TextButton(
                      style: ButtonStyle(
                          backgroundColor: selectedUser == user
                              ? WidgetStateProperty.all<Color>(
                                  selectedUser!.colour)
                              : WidgetStateProperty.all<Color>(Colors.grey)),
                      onPressed: () {
                        setState(() {
                          if (selectedUser?.name == user.name) {
                            selectedUser = null;
                            return;
                          }
                          selectedUser = user;
                        });
                      },
                      child: Text(
                        user.name,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ).toList(),
              ),
              Expanded(
                child: isExtractingText
                    ? const CircularProgressIndicator()
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2.0,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: purchasedItems.length,
                          itemBuilder: (context, index) {
                            Item item = purchasedItems[index];

                            return Material(
                              child: ListTile(
                                title: Text(item.name),
                                subtitle:
                                    Text('\$${item.price.toStringAsFixed(2)}'),
                                trailing: const Icon(Icons.shopping_cart),
                                selectedTileColor: item.selectedColour,
                                selected: item.isSelected,
                                selectedColor: Colors.white,
                                onTap: () {
                                  toggleItem(item);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
              TextButton(
                onPressed: () {
                  calculateSplitCosts();
                },
                child: Text("Calculate!"),
              ),
              Padding(
                padding: EdgeInsets.only(top: 18),
                child: SizedBox(
                  child: Column(
                    children: userCosts.entries.map((entry) {
                      final user = entry.key;
                      final cost = entry.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(user.name),
                          Text("\$ ${cost.toStringAsFixed(2)}"),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
              Text(
                "Total shared cost split: \$ ${totalSharedCostSplitBetweenUsers.toStringAsFixed(2)}",
              ),
              Text(
                "Total cost: \$ ${totalCost.toStringAsFixed(2)}",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SplitSummaryPage()),
                      );
                    },
                    child: Text("Done"),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      price: (json['price'] as num).toDouble(), isSelected: false, // Ensuring it's a double
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
