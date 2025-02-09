import 'package:flutter/material.dart';
import 'package:receipt_split/types/user.dart';
import 'package:receipt_split/widgets/colour_pick_note.dart';

class ListUserItem extends StatefulWidget {
  final User user;
  final Function onPress;
  final bool isSelected;
  final Function(User updatedUser) updateUser;

  const ListUserItem(
      {super.key,
      required this.user,
      required this.onPress,
      required this.isSelected,
      required this.updateUser});

  @override
  State<ListUserItem> createState() => _ListUserItemState();
}

class _ListUserItemState extends State<ListUserItem> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        leading: ColourPickNote(
          user: widget.user,
          onSelect: (user) {
            widget.updateUser(user);
          },
        ),
        title: Text(widget.user.name),
        titleTextStyle: TextStyle(
          fontWeight: widget.isSelected ? FontWeight.bold : null,
        ),
        selectedTileColor: Color.fromRGBO(217, 217, 217, 1),
        selectedColor: Colors.black,
        selected: widget.isSelected,
        onTap: () => widget.onPress(),
      ),
    );
  }
}
