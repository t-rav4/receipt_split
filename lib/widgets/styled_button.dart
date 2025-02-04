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
      onPressed: widget.onTap,
      child: Text(widget.label),
    );
  }
}
