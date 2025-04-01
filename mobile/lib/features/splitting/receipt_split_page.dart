import 'dart:io';
import 'package:flutter/material.dart';
import 'package:receipt_split/features/splitting/receipt_items_list.dart';
import 'package:receipt_split/features/splitting/user_chips_select.dart';
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

  void _handleUserSelection(User? user) {
    setState(() {
      selectedUser = user;
    });
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
      setState(() {
        isExtractingText = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  void toggleItem(Item item) {
    setState(() {
      if (item.assignedUser == null) {
        if (selectedUser != null) {
          item.assignedUser = selectedUser;
          selectedUser?.assignedItems.add(item);
        }
      } else if (selectedUser == null || item.assignedUser == selectedUser) {
        item.assignedUser = null;
        selectedUser?.assignedItems.remove(item);
      } else {
        var previouslyAssignedUser = item.assignedUser;
        previouslyAssignedUser?.assignedItems.remove(item);
        item.assignedUser = selectedUser;
        selectedUser?.assignedItems.add(item);
      }

      calculateSplitCosts();
    });
  }

  void calculateSplitCosts() {
    Map<User, double> userToCostMap = {};

    double totalItemsCost = 0.0;
    double totalSharedCost = 0.0;

    for (User user in widget.users) {
      double usersCost = 0.0;

      for (var item in user.assignedItems) {
        usersCost += item.price;
        totalItemsCost += item.price;
      }

      userToCostMap[user] = usersCost;
    }

    // Calculate total shared cost for unassigned items
    for (Item item in purchasedItems) {
      if (item.assignedUser == null) {
        totalSharedCost += item.price;
      }
    }

    double splitCost = totalSharedCost / userToCostMap.length;

    // Add shared cost to each user's individual cost
    userToCostMap.updateAll((user, cost) => cost + splitCost);

    setState(() {
      userCosts = userToCostMap;
      totalSharedCostSplitBetweenUsers = splitCost;
      totalCost = totalItemsCost + totalSharedCost;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RsLayout(
        content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text("Toggle user select, and split the costs",
            style: TextStyle(fontSize: 16)),
        UserChipsSelect(
          users: widget.users,
          selectedUser: selectedUser,
          onChipSelect: _handleUserSelection,
        ),
        Expanded(
          child: isExtractingText
              ? const CircularProgressIndicator()
              : ReceiptItemsList(
                  items: purchasedItems,
                  onItemSelect: toggleItem,
                ),
        ),
        // TODO: improve design here
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
