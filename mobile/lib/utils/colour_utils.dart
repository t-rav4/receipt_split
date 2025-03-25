import 'dart:math';

import 'package:flutter/material.dart';

Color getRandomColour() {
  final random = Random();
  return Color.fromARGB(
      255, random.nextInt(256), random.nextInt(256), random.nextInt(256));
}

