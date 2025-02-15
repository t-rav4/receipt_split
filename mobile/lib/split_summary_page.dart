import 'package:flutter/material.dart';
import 'package:receipt_split/widgets/list_user_summary_item.dart';
import 'package:receipt_split/widgets/page_layout.dart';
import 'package:receipt_split/widgets/styled_button.dart';

class SplitSummaryPage extends StatefulWidget {
  const SplitSummaryPage({super.key});

  @override
  State<SplitSummaryPage> createState() => _SplitSummaryPageState();
}

class _SplitSummaryPageState extends State<SplitSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return RsLayout(
      showBackButton: true,
      content: Column(
        children: [
          Divider(),
          ListUserSummaryItem(),
          ListUserSummaryItem(),
          ListUserSummaryItem(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Row(
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
