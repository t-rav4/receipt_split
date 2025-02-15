import 'package:flutter/material.dart';

class ListUserSummaryItem extends StatefulWidget {
  const ListUserSummaryItem({super.key});

  @override
  State<ListUserSummaryItem> createState() => _ListUserSummaryItemState();
}

class _ListUserSummaryItemState extends State<ListUserSummaryItem> {

  bool isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "User Name",
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          Text("\$ 00.00"),
        ],
      ),
    );
  }
}
