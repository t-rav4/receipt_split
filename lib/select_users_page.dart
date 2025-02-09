import 'dart:math';

import 'package:flutter/material.dart';
import 'package:receipt_split/services/colour_picker_service.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:receipt_split/widgets/list_user_item.dart';
import 'package:receipt_split/widgets/styled_button.dart';

import 'receipt_split_page.dart';
import 'types/user.dart';

const minRequiredUsers = 2;

Color getRandomColour() {
  final random = Random();
  return Color.fromARGB(
      255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
}

class SelectUsersPage extends StatefulWidget {
  const SelectUsersPage({super.key, required this.selectedPdf});

  final String selectedPdf;

  @override
  State<SelectUsersPage> createState() => _SelectUsersPageState();
}

class _SelectUsersPageState extends State<SelectUsersPage> {
  List<User> userOptions = [];
  List<User> selectedUsers = [];

  var preferenceService = PreferenceService();

  @override
  void initState() {
    _loadUsersFromStorage();

    super.initState();
  }

  Future<void> _loadUsersFromStorage() async {
    List<User> savedUsers = await preferenceService.fetchSavedUsers();
    setState(() {
      userOptions = savedUsers;
    });
  }

  Future<void> _saveUsers() async {
    await preferenceService.saveUsers(userOptions);
  }

  void createNewUser(String name) {
    setState(() {
      final colour = getRandomColour();
      userOptions.add(User(name: name, colour: colour));
    });
  }

  void goToReceiptSplit() async {
    if (selectedUsers.length < minRequiredUsers) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please select at least 2 users"),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    // TODO: check for overwritting any data just in case
    await _saveUsers();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReceiptSplitPage(pdf: widget.selectedPdf, users: selectedUsers),
      ),
    );
  }

  void updateUser(User updatedUser) async {
    setState(() {
      var index = userOptions.indexWhere((u) => u.name == updatedUser.name);
      userOptions[index] = updatedUser;
    });

    await _saveUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back, size: 40),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Please select who you wish to split with!",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          itemCount: userOptions.length + 1,
                          itemBuilder: (context, index) {
                            if (index == userOptions.length) {
                              return ElevatedButton(
                                child: const Text("Add New User"),
                                onPressed: () {
                                  showAddUserDialog(
                                      context, (name) => createNewUser(name));
                                },
                              );
                            }
                            User user = userOptions[index];
                            return ListUserItem(
                              user: user,
                              onPress: () {
                                setState(() {
                                  if (selectedUsers.contains(user)) {
                                    selectedUsers.remove(user);
                                    return;
                                  }
                                  selectedUsers.add(user);
                                });
                              },
                              isSelected: selectedUsers.contains(user),
                              updateUser: updateUser

                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: StyledButton(
                label: "Split",
                onTap: () => goToReceiptSplit(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
