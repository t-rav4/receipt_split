import 'package:flutter/material.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/shared/widgets/list_user_item.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final List<String> selectedIds;
  final Function(User) onSelectUser;
  // final Function(User) onUpdateUser;

  const UserList({
    super.key,
    required this.users,
    required this.selectedIds,
    required this.onSelectUser,
    // required this.onUpdateUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: (context, index) {
        User user = users[index];
        return ListUserItem(
            user: user,
            onPress: () {
              onSelectUser(user);
            },
            isSelected: selectedIds.contains(user.id),
            updateUser: (User user) {
              // onUpdateUser(user); TODO
            });
      },
      separatorBuilder: (context, index) => SizedBox(height: 6),
      itemCount: users.length,
    );
  }
}
