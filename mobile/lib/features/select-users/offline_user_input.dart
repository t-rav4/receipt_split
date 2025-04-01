import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:receipt_split/features/select-users/select_users_provider.dart';
import 'package:receipt_split/features/select-users/user_list.dart';

class OfflineUserInput extends StatelessWidget {
  final TextEditingController textController = TextEditingController();

  OfflineUserInput({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SelectUsersProvider>(context);

    return Column(
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: "Enter user name",
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (textController.text.isEmpty) return;

                var user = provider.createNewUser(textController.text);
                provider.toggleUserSelection(user.id);
                textController.clear();
              },
            ),
          ),
        ),
        const SizedBox(height: 15),
        provider.userOptions.isEmpty
            ? const Text("No users created yet")
            : Expanded(
                child: UserList(
                  users: provider.userOptions,
                  selectedIds: provider.selectedUsers.map((u) => u.id).toList(),
                  onSelectUser: provider.toggleUserSelection,
                ),
              ),
      ],
    );
  }
}
