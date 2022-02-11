import 'dart:async';

import 'package:flutter/material.dart';

import 'game.dart';

class Countdown extends StatefulWidget {
  final Game game;

  const Countdown(this.game, {Key? key}) : super(key: key);

  @override
  CountdownState createState() => CountdownState();
}

class CountdownState extends State<Countdown> {
  double _timerValue = 0;

  double _levelTime = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.game.setCountdownState(this);
  }

  void start(double levelTime) {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 10),
      (Timer timer) {
        // debugPrint('timer tick ${timer.tick}');
        setState(() {
          if (_timerValue <= 0) {
            timer.cancel();
            widget.game.onTimerFinished();
          } else {
            _timerValue = _levelTime - timer.tick * 0.01;
            if (_timerValue < 0) {
              _timerValue = 0;
            }

            widget.game.tick(_timerValue);
          }
        });
        // onTimerTick?.call(_timerValue);
      },
    );

    setState(() {
      _timerValue = levelTime;
      _levelTime = levelTime;
    });
  }

  void solved() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const duration = Duration(milliseconds: 200);

    return AnimatedPositioned(
      top: screenSize.height / 2 -
          widget.game.getPuzzleScreenSize() / 2 -
          70 -
          ((widget.game.showCountdown() || widget.game.levelTime == 0) ? 0 : 40),
      duration: duration,
      child: AnimatedOpacity(
        opacity: widget.game.showCountdown() ? 1 : 0,
        duration: duration,
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade400.withOpacity(0.5),
                spreadRadius: 3,
                blurRadius: 6,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _timerValue.toInt().toString(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: "AzeretMono",
                        color: Colors.blue.shade600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      (_timerValue - _timerValue.toInt()).toStringAsFixed(2).substring(2),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "AzeretMono",
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
                if (Game.instance.levelTime > 0)
                  LinearProgressIndicator(
                    value: _timerValue / Game.instance.levelTime,
                    backgroundColor: Colors.blue.shade50,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
