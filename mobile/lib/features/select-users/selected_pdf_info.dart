import 'package:flutter/material.dart';

class SelectedPdfInfo extends StatelessWidget {
  final String pdf;

  const SelectedPdfInfo({super.key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text(
          "Selected:",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            pdf,
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
