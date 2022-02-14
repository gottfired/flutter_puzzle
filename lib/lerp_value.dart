import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class LerpValue {
  double value = 0;
  double currentTime = 0;
  double from = 0;
  double to = 0;
  double durationSeconds = 0;
  final curve = Curves.easeInOut;

  LerpValue(double? value) {
    if (value != null) {
      this.value = value;
      from = value;
      to = value;
    }
  }

  void set(double value) {
    this.value = value;
    from = value;
    to = value;
    durationSeconds = 0;
  }

  void lerpTo(double to, [double durationSeconds = 1]) {
    if (to == this.to && durationSeconds == this.durationSeconds) {
      return;
    }

    from = value;
    this.to = to;
    this.durationSeconds = durationSeconds;
    currentTime = 0;
  }

  void tick(double dt) {
    if (durationSeconds == 0) {
      value = to;
      return;
    }

    currentTime += dt;
    if (currentTime >= durationSeconds) {
      value = to;
    } else {
      final t = max(0.0, min(1.0, currentTime / durationSeconds));
      value = from + curve.transform(t) * (to - from);
    }
  }
}
