import 'package:flutter/material.dart';
import 'package:receipt_split/models/user.dart';

class UserChipsSelect extends StatelessWidget {
  final List<User> users;
  final User? selectedUser;
  final Function(User) onChipSelect;

  const UserChipsSelect(
      {super.key,
      required this.users,
      required this.onChipSelect,
      this.selectedUser});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: users.map(
        (user) {
          return TextButton(
            style: ButtonStyle(
               backgroundColor: WidgetStateProperty.all<Color>(
                selectedUser?.name == user.name ? selectedUser!.colour : Colors.grey,
              ),
            ),
            onPressed: () {
              onChipSelect(user);
            },
            child: Text(
              user.name,
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ).toList(),
    );
  }
}
