import 'package:flutter/material.dart';
import 'package:receipt_split/services/colour_picker_service.dart';
import 'package:receipt_split/models/user.dart';

class ColourPickNote extends StatefulWidget {
  final User user;
  final Function(User user) onSelect;
  const ColourPickNote(
      {super.key, required this.user, required this.onSelect});

  @override
  State<ColourPickNote> createState() => _ColourPickNoteState();
}

class _ColourPickNoteState extends State<ColourPickNote> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Color? selectedColour = await openColourSelectForUser(context, widget.user.colour);
        
        if (selectedColour != null) {
          User updatedUser = widget.user.copyWith(colour: selectedColour);
          widget.onSelect(updatedUser);
        }
      },
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: widget.user.colour,
          borderRadius: BorderRadius.all(
            Radius.circular(100),
          ),
        ),
      ),
    );
  }
}
