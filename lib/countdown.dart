import 'dart:async';
import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  final int seconds;

  const Countdown({Key? key, required this.seconds}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountdownState(seconds);
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;
  double _value = 0;

  _CountdownState(int seconds) {
    startTimer(seconds);
  }

  void startTimer(int seconds) {
    _value = seconds.toDouble();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (Timer timer) => setState(
        () {
          if (_value <= 0) {
            timer.cancel();
          } else {
            _value -= 0.01;
            if (_value < 0) {
              _value = 0;
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        _value.toInt().toString(),
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
