import 'package:flutter/material.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:receipt_split/services/user_service.dart';
import 'package:receipt_split/utils/colour_utils.dart';
import 'package:uuid/uuid.dart';

class SelectUsersProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final PreferenceService _preferenceService = PreferenceService();

  List<User> userOptions = [];
  List<User> selectedUsers = [];
  bool isOffline = false;

  SelectUsersProvider() {
    _loadOfflineMode();
  }

  Future<void> _loadOfflineMode() async {
    isOffline = await _preferenceService.getOfflineMode();
    notifyListeners();
  }

  Future<List<User>> fetchUsers() async {
    userOptions = await _userService.getAllUsers();
    notifyListeners();
    return userOptions;
  }

  void createNewUser(String name) async {
    final user = User(
      id: Uuid().toString(),
      name: name,
      colour: getRandomColour(),
    );

    userOptions.add(user);
    notifyListeners();
  }

  void updateUser(User user) async {
    User updatedUser =
        await _userService.updateUser(user.id, user.name, user.colour);

    int index = userOptions.indexWhere((u) => u.id == user.id);
    if (index != -1) {
      userOptions[index] = updatedUser;
      notifyListeners();
    }
  }

  void toggleUserSelection(String userId) {
    if (selectedUsers.any((user) => user.id == userId)) {
      selectedUsers.removeWhere((user) => user.id == userId);
    } else {
      final user = userOptions.firstWhere((user) => user.id == userId);
      selectedUsers.add(user);
    }

    notifyListeners();
  }
}
