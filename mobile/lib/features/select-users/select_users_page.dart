import 'package:flutter/material.dart';
import 'package:receipt_split/features/select-users/user_list.dart';
import 'package:receipt_split/features/shared/loading_spinner.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/pages/receipt_split_page.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:receipt_split/services/user_service.dart';
import 'package:receipt_split/utils/colour_utils.dart';
import 'package:receipt_split/widgets/page_layout.dart';
import 'package:receipt_split/widgets/styled_button.dart';

const minRequiredUsers = 2;

class SelectUsersPage extends StatefulWidget {
  const SelectUsersPage({super.key, required this.selectedPdf});

  final String selectedPdf;

  @override
  State<SelectUsersPage> createState() => _SelectUsersPageState();
}

class _SelectUsersPageState extends State<SelectUsersPage> {
  List<User> userOptions = [];
  List<User> selectedUsers = [];
  bool isOffline = false;
  TextEditingController userTextController = TextEditingController();

  var userSerivce = UserService();
  var preferenceService = PreferenceService();

  @override
  void initState() {
    preferenceService.getOfflineMode().then((response) {
      setState(() => isOffline = response);
    });
    super.initState();
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

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUsers.any((user) => user.id == userId)) {
        selectedUsers.removeWhere((user) => user.id == userId);
      } else {
        final user = userOptions.firstWhere((user) => user.id == userId);
        selectedUsers.add(user);
      }
    });
  }

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
              if (isOffline) ...[
                TextField(
                  controller: userTextController,
                  decoration: InputDecoration(
                    labelText: "Enter user name",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (userTextController.text.isEmpty) {
                          return;
                        }
                        setState(() {
                          userOptions.add(User(
                              id: userOptions.length.toString(),
                              name: userTextController.text,
                              colour: getRandomColour()));
                        });
                        userTextController.clear();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: userOptions.isEmpty
                      ? const Text("No users created yet.")
                      : UserList(
                          users: userOptions,
                          selectedIds: selectedUsers.map((u) => u.id).toList(),
                          onSelectUser: toggleUserSelection,
                        ),
                ),
              ] else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "Please select who you wish to split with!",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                // User List Section
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FutureBuilder<List<User>>(
                      future: userSerivce.getAllUsers(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return UserList(
                            users: snapshot.data!,
                            selectedIds:
                                selectedUsers.map((u) => u.id).toList(),
                            onSelectUser: toggleUserSelection,
                          );
                        }
                        if (snapshot.hasError) {
                          return Text(
                              "Something went wrong whilst fetching users");
                        }

                        return LoadingSpinner();
                      },
                    ),
                  ),
                ),
              ],
              Container(
                alignment: Alignment.centerRight,
                child: StyledButton(
                  label: "Split",
                  onTap: goToReceiptSplit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
