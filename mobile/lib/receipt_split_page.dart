import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';
import 'package:receipt_split/services/split_service.dart';
import 'package:receipt_split/split_summary_page.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/widgets/page_layout.dart';
import 'package:receipt_split/widgets/styled_button.dart';

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

  var splitService = SplitService();
  var isExtractingText = false;

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

      File file = File(widget.pdf);
      List<Item> items = await splitService.extractItemsFromReceipt(file);

      // Init the map for item to users to empty
      Map<Item, User?> emptyItemToUserMap = {
        for (var item in items) item: null
      };
      Map<User, double> emptyUserCostsMap = {
        for (var user in widget.users) user: 0.0
      };

      setState(() {
        purchasedItems = items;
        isExtractingText = false;
        itemToUserRecord = emptyItemToUserMap;
        userCosts = emptyUserCostsMap;
      });

      calculateSplitCosts();
    } catch (e) {
      print("An error ocurred ${e.toString()}");
      setState(() {
        isExtractingText = false;
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
    return RsLayout(
        showBackButton: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Text("Toggle user select, and split the costs",
                style: TextStyle(fontSize: 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.users.map(
                (user) {
                  return TextButton(
                    style: ButtonStyle(
                      backgroundColor: selectedUser == user
                          ? WidgetStateProperty.all<Color>(selectedUser!.colour)
                          : WidgetStateProperty.all<Color>(Colors.grey),
                    ),
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
                          width: 1,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                        borderRadius: BorderRadius.circular(1),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        itemCount: purchasedItems.length,
                        itemBuilder: (context, index) {
                          Item item = purchasedItems[index];

                          return Material(
                            child: ListTile(
                              title: Text(item.name),
                              trailing: Text(
                                '\$${item.price.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 16),
                              ),
                              selectedTileColor: item.selectedColour,
                              selected: item.isSelected,
                              selectedColor: Colors.white,
                              onTap: () {
                                toggleItem(item);
                              },
                              // shape: LinearBorder.bottom(
                              //   side: BorderSide(color: Colors.grey, width: 1),
                              // ),
                            ),
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(),
                      ),
                    ),
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
                StyledButton(
                    label: "Go to Summary",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SplitSummaryPage()),
                      );
                    }),
              ],
            ),
          ],
        ));
  }
}
