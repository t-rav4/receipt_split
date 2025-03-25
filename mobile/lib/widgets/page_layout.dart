import 'package:flutter/material.dart';

class RsLayout extends StatelessWidget {
  final Widget content;
  final bool? showBackButton;
  final String? title;

  const RsLayout(
      {super.key,
      required this.content,
      this.showBackButton = false,
      this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
