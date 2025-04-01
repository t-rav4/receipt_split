import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/services/split_service.dart';

class ReceiptSplitProvider extends ChangeNotifier {
  final SplitService _splitService = SplitService();

  ReceiptSplitProvider(String pdfFilePath, List<User> users) {
    userOptions = users;
    extractTextFromPdf(pdfFilePath);
    notifyListeners();
  }

  List<User> userOptions = [];

  List<Item> purchasedItems = [];
  Map<User, double> userCosts = {};

  User? selectedUser;
  bool isExtractingText = false;

  double totalSharedCostSplitBetweenUsers = 0.0;
  double totalCost = 0.0;

  void calculateSplitCosts() {
    Map<User, double> userToCostMap = {};

    double totalItemsCost = 0.0;
    double totalSharedCost = 0.0;

    for (User user in userOptions) {
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

    userCosts = userToCostMap;
    totalSharedCostSplitBetweenUsers = splitCost;
    totalCost = totalItemsCost + totalSharedCost;
    notifyListeners();
  }

  void toggleItem(Item item) {
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

    notifyListeners();
  }

  void handleUserSelection(User? user) {
    selectedUser = user;
    notifyListeners();
  }

  Future<void> extractTextFromPdf(String pdfFilePath) async {
    try {
      isExtractingText = true;
      notifyListeners();

      File file = File(pdfFilePath);
      List<Item> items = await _splitService.extractItemsFromReceipt(file);

      Map<User, double> emptyUserCostsMap = {
        for (var user in userOptions) user: 0.0
      };

      purchasedItems = items;
      isExtractingText = false;
      userCosts = emptyUserCostsMap;

      calculateSplitCosts();
    } catch (e) {
      isExtractingText = false;

      // TODO: figure out best way of showing snackbar on error here (perhaps error middleware at top app level?)
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text("Error: ${e.toString()}")),
      // );
    } finally {
      notifyListeners();
    }
  }
}
