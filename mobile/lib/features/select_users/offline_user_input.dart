import 'package:flutter/material.dart';
import 'package:receipt_split/features/select_users/user_list.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/utils/colour_utils.dart';
import 'package:uuid/uuid.dart';

class OfflineUserInput extends StatefulWidget {
  final List<User> userOptions;
  final List<String> selectedIds;
  final void Function(User) onUserAdded;
  final void Function(User) onUserRemoved;
  final void Function(User) onUserToggleSelect;

  const OfflineUserInput({
    super.key,
    required this.userOptions,
    required this.selectedIds,
    required this.onUserAdded,
    required this.onUserRemoved,
    required this.onUserToggleSelect,
  });

  @override
  State<OfflineUserInput> createState() => _OfflineUserInputState();
}

class _OfflineUserInputState extends State<OfflineUserInput> {
  final TextEditingController textController = TextEditingController();

  void _handleAddUser() {
    if (textController.text.isEmpty) return;

    final newUser = User(
      id: Uuid().v4(),
      name: textController.text,
      colour: getRandomColour(),
    );

    widget.onUserAdded(newUser);
    textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            labelText: "Enter user name",
            suffixIcon: IconButton(
              icon: Icon(Icons.add),
              onPressed: _handleAddUser,
            ),
          ),
        ),
        const SizedBox(height: 15),
        widget.userOptions.isEmpty
            ? const Text("No users created yet")
            : Expanded(
                child: UserList(
                  users: widget.userOptions,
                  selectedIds: widget.selectedIds,
                  onSelectUser: widget.onUserToggleSelect,
                  // onUpdateUser: widget.onUserToggleSelect,
                ),
              ),
      ],
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }
}
