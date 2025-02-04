import 'dart:math';

import 'package:flutter/material.dart';
import 'package:receipt_split/services/preferences_service.dart';
import 'package:receipt_split/widgets/styled_button.dart';

import 'receipt_split_page.dart';
import 'types/user.dart';

List<Color> userPredefinedColours = [
  Colors.redAccent,
  Colors.pink,
  Colors.purpleAccent,
  Colors.deepPurple,
  Colors.indigoAccent,
  Colors.blue,
  Colors.lightBlueAccent,
  Colors.teal,
  Colors.tealAccent,
  Colors.green,
  Colors.lightGreenAccent,
  Colors.greenAccent,
  Colors.yellow,
  Colors.orange,
  Colors.deepOrange,
  Colors.brown,
  Colors.grey,
  Colors.blueGrey
];

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
    if (selectedUsers.length < 2) {
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

  void openColourSelectForUser(BuildContext context, User user) {
    // Navigator.pop(context); // Close the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select a colour"),
          content: Padding(
            padding: EdgeInsets.all(24),
            child: Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: userPredefinedColours
                  .map(
                    (colour) => GestureDetector(
                      onTap: () {
                        setState(() {
                          userOptions
                              .firstWhere((u) => u.name == user.name)
                              .colour = colour;
                        });
                        Navigator.pop(context); // Close pop-up
                      },
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          border: user.colour == colour
                              ? Border.all(
                                  width: 4,
                                  color: Colors.white,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                )
                              : null,
                          color: colour,
                          borderRadius: BorderRadius.all(
                            Radius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        );
      },
    );
  }

  void showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController controller = TextEditingController();

        return AlertDialog(
          title: const Text("Enter name"),
          content: TextField(
            textCapitalization: TextCapitalization.words,
            controller: controller,
            decoration: const InputDecoration(
              labelText: "Name",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                String newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  createNewUser(newName);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
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

           
            Text("Please select who you wish to split with!"),
            Expanded(
              child: ListView.builder(
                  itemCount: userOptions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == userOptions.length) {
                      return ElevatedButton(
                        child: const Text("Add New User"),
                        onPressed: () {
                          showAddUserDialog(context);
                        },
                      );
                    }
                    User user = userOptions[index];
                    return Material(
                      child: ListTile(
                        leading: GestureDetector(
                          onTap: () {
                            openColourSelectForUser(context, user);
                          },
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: user.colour,
                              borderRadius: BorderRadius.all(
                                Radius.circular(100),
                              ),
                            ),
                          ),
                        ),
                        title: Text(user.name),
                        titleTextStyle: TextStyle(
                            fontWeight: selectedUsers.contains(user)
                                ? FontWeight.bold
                                : null),
                        selectedColor: Colors.white,
                        selected: selectedUsers.contains(user),
                        onTap: () {
                          setState(() {
                            if (selectedUsers.contains(user)) {
                              selectedUsers.remove(user);
                              return;
                            }
                            selectedUsers.add(user);
                          });
                        },
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton:
          StyledButton(label: "Split", onTap: () => goToReceiptSplit()),
    );
  }
}
