import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  bool isMobile() {
    return MediaQuery.of(this).size.width < 600;
  }
}
