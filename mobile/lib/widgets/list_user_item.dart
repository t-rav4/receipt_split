import 'package:flutter/material.dart';
import 'package:receipt_split/models/user.dart';
import 'package:receipt_split/widgets/colour_pick_note.dart';

class ListUserItem extends StatefulWidget {
  final User user;
  final Function onPress;
  final bool isSelected;
  final Function(User updatedUser) updateUser;
  final Function? onTrailingPress;

  const ListUserItem({
    super.key,
    required this.user,
    required this.onPress,
    required this.isSelected,
    required this.updateUser,
    this.onTrailingPress,
  });

  @override
  State<ListUserItem> createState() => _ListUserItemState();
}

class _ListUserItemState extends State<ListUserItem> {
  Widget? trailingWidget;

  @override
  Widget build(BuildContext context) {
    if (widget.onTrailingPress != null) {
      trailingWidget = IconButton(
        onPressed: () {
          widget.onTrailingPress!();
        },
        icon: Icon(Icons.more_vert_rounded),
      );
    }

    return Material(
      child: ListTile(
          leading: ColourPickNote(
            user: widget.user,
            onSelect: (user) {
              widget.updateUser(user);
            },
          ),
          trailing: trailingWidget,
          title: Text(widget.user.name),
          titleTextStyle: TextStyle(
            fontWeight: widget.isSelected ? FontWeight.bold : null,
            fontSize: 18.0,
          ),
          selectedTileColor: Color.fromRGBO(217, 217, 217, 1),
          selectedColor: Colors.black,
          selected: widget.isSelected,
          onTap: () => widget.onPress(),
          contentPadding: EdgeInsets.only(left: 12)),
    );
  }
}
