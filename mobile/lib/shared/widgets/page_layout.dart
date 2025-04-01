import 'package:flutter/material.dart';

class RsLayout extends StatelessWidget {
  final Widget content;
  final String? title;

  final EdgeInsetsGeometry? padding;

  const RsLayout({super.key, required this.content, this.title, this.padding});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: title != null ? Text(title!) : null,
      ),
      body: SafeArea(
        child: Container(
          padding: padding ?? const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: content,
        ),
      ),
    );
  }
}
