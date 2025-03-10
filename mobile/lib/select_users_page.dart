import 'dart:math';

import 'package:flutter/material.dart';
import 'package:receipt_split/services/colour_picker_service.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:receipt_split/services/user_service.dart';
import 'package:receipt_split/widgets/list_user_item.dart';
import 'package:receipt_split/widgets/page_layout.dart';
import 'package:receipt_split/widgets/styled_button.dart';

import 'receipt_split_page.dart';
import 'models/user.dart';

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

  bool fetchingUsers = true;

  var userSerivce = UserService();
  var preferenceService = PreferenceService();

  @override
  void initState() {
    _fetchUsersFromApi();

    super.initState();
  }

  Future<void> _fetchUsersFromApi() async {
    List<User> fetchedUsers = await userSerivce.getUsers();
    setState(() {
      userOptions = fetchedUsers;
      fetchingUsers = false;
    });
  }

  void createNewUser(String name) async {
    final colour = getRandomColour();

    User createdUser = await userSerivce.createUser(name, colour);

    setState(() {
      userOptions.add(createdUser);
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ReceiptSplitPage(pdf: widget.selectedPdf, users: selectedUsers),
      ),
    );
  }

  void updateUser(User user) async {
    User updatedUser =
        await userSerivce.updateUser(user.id, user.name, user.colour);
    setState(() {
      var index = userOptions.indexWhere((u) => u.name == updatedUser.name);
      userOptions[index] = updatedUser;
    });
  }

  void showUserOptionsDialog() {}

  @override
  Widget build(BuildContext context) {
    return RsLayout(
      showBackButton: true,
      content: Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 15.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text(
                    "Selected:",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      widget.selectedPdf,
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "Please select who you wish to split with!",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: fetchingUsers
                      ? Center(
                          child: Transform.scale(
                            scale: 2,
                            child: CircularProgressIndicator(
                              strokeCap: StrokeCap.round,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      : ListView.separated(
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 6),
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
                                updateUser: updateUser,
                                onTrailingPress: () {
                                  userSerivce.showUserOptionsDialog(
                                      context, user.id);
                                });
                          },
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
      ),
    );
  }
}
