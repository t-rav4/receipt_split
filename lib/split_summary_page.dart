import 'package:flutter/material.dart';

class SplitSummaryPage extends StatefulWidget {
  const SplitSummaryPage({super.key});

  @override
  State<SplitSummaryPage> createState() => _SplitSummaryPageState();
}

class _SplitSummaryPageState extends State<SplitSummaryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: Column(
            children: [
              Text("Hello"),
            ],
          ),
        ),
      ),
    );
  }
}
