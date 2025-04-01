import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';
import 'package:receipt_split/models/user.dart';

class ListUserSummaryItem extends StatefulWidget {
  final User user;

  const ListUserSummaryItem({super.key, required this.user});

  @override
  State<ListUserSummaryItem> createState() => _ListUserSummaryItemState();
}

class _ListUserSummaryItemState extends State<ListUserSummaryItem> {
  @override
  Widget build(BuildContext context) {
    User user = widget.user;
    List<Item> items = widget.user.assignedItems;
    double totalCost = 0.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: ExpansionTile(
          trailing: Text("\$${totalCost.toStringAsFixed(2)}"),
          title: Text(
            user.name,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          children: items.isNotEmpty
              ? items
                  .map(
                    (item) => ListTile(
                      title: Text(item.name),
                      trailing: Text("\$${item.price.toStringAsFixed(2)}"),
                    ),
                  )
                  .toList()
              : []),
    );
  }
}
