import 'package:flutter/material.dart';
import 'package:receipt_split/constants/colours.dart';

Future<Color?> openColourSelectForUser(BuildContext context, Color? currentColour) {
  return showDialog<Color?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Select a colour"),
        content: Padding(
          padding: EdgeInsets.all(24),
          child: Wrap(
            spacing: 10.0,
            runSpacing: 10.0,
            children: colours
                .map(
                  (colour) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context, colour); // Close pop-up + return this colour
                    },
                    child: Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        border: currentColour == colour
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

void showAddUserDialog(BuildContext context, Function(String name) onCreate) {
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
                onCreate(newName);
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
