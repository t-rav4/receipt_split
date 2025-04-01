import 'package:flutter/material.dart';
import 'package:receipt_split/models/item.dart';

class ReceiptItemsList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onItemSelect;

  const ReceiptItemsList({super.key, required this.items, required this.onItemSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 0.5,
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 6),
        itemCount: items.length,
        itemBuilder: (context, index) {
          Item item = items[index];

          return Material(
            child: ListTile(
              title: Text(item.name),
              trailing: Text(
                '\$${item.price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16),
              ),
              selectedTileColor:
                  item.assignedUser?.colour ?? Colors.transparent,
              selected: item.assignedUser != null,
              selectedColor: Colors.white,
              onTap: () {
                onItemSelect(item);
              },
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) => const Divider(),
      ),
    );
  }
}
