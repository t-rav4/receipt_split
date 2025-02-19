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
      body: SafeArea(
        child: Column(
          children: [
            if (showBackButton ?? false)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 32),
                      ),
                      if (title != null)
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
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
