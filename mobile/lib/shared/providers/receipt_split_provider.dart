import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/services/split_service.dart';

class ReceiptSplitProvider extends ChangeNotifier {
  late File selectedPdf;

  List<User> userOptions = [];
  List<User> selectedUsers = [];

  final SplitService _splitService;
  bool isExtractingText = false;
  List<Item> receiptItems = [];
  User? selectedUser;
  Map<User, double> userCosts = {};
  double totalCost = 0.0;
  double totalSharedCostSplitBetweenUsers = 0.0;

  ReceiptSplitProvider(this._splitService);

  void selectPdf(File pdf) {
    selectedPdf = pdf;
    notifyListeners();
  }

  void addUserOption(User user) {
    if (userOptions.contains(user)) {
      // TODO: cant re-add same user
    } else {
      userOptions.add(user);
      notifyListeners();
    }
  }

  void removeUserOption(User user) {
    selectedUsers.removeWhere((u) => u.id == user.id);
    notifyListeners();
  }

  void updateUser(User user) {} // TODO

  void toggleUserSelect(User user) {
    if (selectedUsers.contains(user)) {
      selectedUsers.remove(user);
    } else {
      selectedUsers.add(user);
    }
    notifyListeners();
  }

  void setReceiptItems(List<Item> items) {
    receiptItems = items;
    notifyListeners();
  }

  Future<void> loadItemsFromReceiptPdf() async {
    isExtractingText = true;
    notifyListeners();

    try {
      receiptItems = await _splitService.extractItemsFromReceipt(selectedPdf);
      _calculateTotalCost();
    } catch (error) {
      // TODO: should show snackbar alert / update UI 
    } finally {
      isExtractingText = false;
      notifyListeners();
    }
  }

  void handleUserSelection(User user) {
    selectedUser = user;
    notifyListeners();
  }

  void _calculateTotalCost() {
    totalCost = receiptItems.fold(0, (sum, item) => sum + item.price);
    _recalculateUserCosts();
  }

  void toggleItem(Item item) {
    if (selectedUser == null) return;

    if (item.assignedUser == selectedUser) {
      item.assignedUser = null;
    } else {
      item.assignedUser = selectedUser;
    }

    _recalculateUserCosts();
    notifyListeners();
  }

  void _recalculateUserCosts() {
    userCosts.clear();

    var sharedItemsCost =
        receiptItems.where((item) => item.assignedUser == null).fold(
              0.0,
              (sum, item) => sum + item.price,
            );

    totalSharedCostSplitBetweenUsers =
        selectedUsers.isNotEmpty ? sharedItemsCost / selectedUsers.length : 0;

    for (var user in selectedUsers) {
      userCosts[user] =
          receiptItems.where((item) => item.assignedUser == user).fold(
                    0.0,
                    (sum, item) => sum + item.price,
                  ) +
              totalSharedCostSplitBetweenUsers;
    }

    notifyListeners();
  }
}
