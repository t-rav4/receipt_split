import 'package:flutter/material.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/services/user_service.dart';
import 'package:receipt_split/utils/colour_utils.dart';
import 'package:uuid/uuid.dart';

class SelectUsersProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<User> userOptions = [];
  Set<User> selectedUsers = {};

  List<User> get selectedUsersList => selectedUsers.toList();

  void fetchUsers() async {
    userOptions = await _userService.getAllUsers();
    notifyListeners();
  }

  User createNewUser(String name, {bool initiallySelected = false}) {
    // TODO: would likely make sense here if the userservice created the user
    final user = User(
      id: Uuid().v4().toString(),
      name: name,
      colour: getRandomColour(),
    );

    userOptions.add(user);

    if (initiallySelected) {
      toggleUserSelection(user.id);
    }

    notifyListeners();
    return user;
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
    final user = userOptions.firstWhere((user) => user.id == userId);

    if (selectedUsers.contains(user)) {
      selectedUsers.remove(user);
    } else {
      selectedUsers.add(user);
    }

    notifyListeners();
  }
}
