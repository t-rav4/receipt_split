import 'package:flutter/material.dart';

class RsLayout extends StatelessWidget {
  final Widget content;
  final bool? showBackButton;

  const RsLayout(
      {super.key, required this.content, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showBackButton ?? false)
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_rounded, size: 40),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
