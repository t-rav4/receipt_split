import 'package:flutter/material.dart';

class StyledButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const StyledButton({super.key, required this.label, required this.onTap});

  @override
  State<StyledButton> createState() => _StyledButtonState();
}

class _StyledButtonState extends State<StyledButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      onPressed: widget.onTap,
      child: Text(
        widget.label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
