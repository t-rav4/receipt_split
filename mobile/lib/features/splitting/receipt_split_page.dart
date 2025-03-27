import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';
import 'package:receipt_split/pages/split_summary_page.dart';
import 'package:receipt_split/services/split_service.dart';
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

      Map<User, double> emptyUserCostsMap = {
        for (var user in widget.users) user: 0.0
      };

      setState(() {
        purchasedItems = items;
        isExtractingText = false;
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
    if (item.assignedUser == null) {
      // Item is unassigned + User is selected: allocate item to user
      if (selectedUser != null) {
        setState(() {
          item.assignedUser = selectedUser;
          selectedUser?.assignedItems.add(item);
        });
      }
      calculateSplitCosts();
      return;
    }

    // Item is alreayd allocated

    // Unassign item if toggling with assigned user or when no user is selected
    if (selectedUser == null || item.assignedUser == selectedUser) {
      setState(() {
        item.assignedUser = null;
        selectedUser?.assignedItems.remove(item);
      });
      calculateSplitCosts();
      return;
    }

    // Assign item to selected user
    setState(() {
      var previouslyAssignedUser = item.assignedUser;
      previouslyAssignedUser?.assignedItems.remove(item);

      item.assignedUser = selectedUser;
      selectedUser?.assignedItems.add(item);
    });
    
    calculateSplitCosts();
  }

  void calculateSplitCosts() {
    Map<User, double> userToCostMap = {
      for (var user in widget.users) user: 0.0
    };

    double totalItemsCost = 0.0;

    for (User user in widget.users) {
      var usersCost = 0.0;
      for (var item in user.assignedItems) {
        usersCost += item.price;
      }

      userToCostMap[user] = usersCost;
    }

    double totalSharedCost = 0.0;

    for (Item item in purchasedItems) {
      if (item.assignedUser == null) {
        totalSharedCost += item.price;
      }
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
                              selectedTileColor: item.assignedUser?.colour ??
                                  Colors.transparent,
                              selected: item.assignedUser != null,
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
                          builder: (context) => SplitSummaryPage(
                            users: widget.users,
                            userCosts: userCosts,
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ],
        ));
  }
}
