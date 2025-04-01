import 'package:flutter/material.dart';
import 'package:receipt_split/features/select_users/receipt_split_provider.dart';
import 'package:receipt_split/features/select_users/user_list.dart';
import 'package:receipt_split/features/shared/loading_spinner.dart';
import 'package:receipt_split/models/user.dart';

// TODO: fix this widget
class UserListSection extends StatelessWidget {
  const UserListSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "Please select who you wish to split with!",
            style: TextStyle(fontSize: 18),
          ),
        ),
        // User List Section
        // Container(
        //   padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        //   decoration: BoxDecoration(
        //     border: Border.all(color: Colors.grey, width: 0.2),
        //     borderRadius: BorderRadius.circular(12),
        //   ),
        //   child: FutureBuilder<List<User>>(
        //     future: provider.userOptions.isNotEmpty ? Future.value(provider.userOptions): provider.fetchUsers(),
        //     builder: (context, snapshot) {
        //       if (snapshot.hasData) {
        //         return UserList(
        //           users: snapshot.data!,
        //           selectedIds: provider.selectedUsers.map((u) => u.id).toList(),
        //           onSelectUser: provider.toggleUserSelection,
        //         );
        //       }
        //       if (snapshot.hasError) {
        //         return Text("Something went wrong whilst fetching users");
        //       }

        //       return LoadingSpinner();
        //     },
        //   ),
        // ),
      ],
    );
  }
}
