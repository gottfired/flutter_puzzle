import 'dart:async';
import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  final int seconds;

  const Countdown({Key? key, required this.seconds}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Timer? _timer;
  double _value = 0;

  _CountdownState() {
    // _value = widget.seconds.toDouble();
    // _value = widget.seconds.toDouble();
  }

  void startTimer() {
    _value = widget.seconds.toDouble();
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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            startTimer();
          },
          child: const Text("start"),
        ),
        Text(_value.toStringAsFixed(2)),
      ],
    );
  }
}
