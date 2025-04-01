import 'package:flutter/material.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/widgets/list_user_summary_item.dart';
import 'package:receipt_split/widgets/page_layout.dart';
import 'package:receipt_split/widgets/styled_button.dart';

class SplitSummaryPage extends StatefulWidget {
  final List<User> users;
  final Map<User, double> userCosts;

  const SplitSummaryPage(
      {super.key, required this.users, required this.userCosts});

  @override
  State<SplitSummaryPage> createState() => _SplitSummaryPageState();
}

class _SplitSummaryPageState extends State<SplitSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return RsLayout(
      title: "Split Cost Summary",

      content: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                User user = widget.users[index];
                return ListUserSummaryItem(user: user);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StyledButton(label: "Save", onTap: () {}),
                StyledButton(label: "Home", onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
