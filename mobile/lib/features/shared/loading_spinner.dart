import 'package:flutter/material.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Transform.scale(
        scale: 2,
        child: CircularProgressIndicator(
          strokeCap: StrokeCap.round,
          color: Colors.blue,
        ),
      ),
    );
  }
}
