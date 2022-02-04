import 'dart:async';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_puzzle/background.dart';
import 'package:flutter_puzzle/state_transition.dart';

import 'config.dart';
import 'game.dart';
import 'grid.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushtrix',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: "Rowdies",
      ),
      home: const MainPage(title: 'Pushtrix'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _game = Game();
  double? puzzleTop = 0;
  double puzzleRotation = 0;
  double timerValue = 0;

  void setPuzzleTop(double? top) {
    // debugPrint("new top $top");
    puzzleTop = top;
  }

  _buildCountdown(Size screenSize) {
    return Positioned(
      top: screenSize.height / 2 - _game.getPuzzleScreenSize() / 2 - 70,
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
                    timerValue.toInt().toString(),
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: "AzeretMono",
                      color: Colors.blue.shade600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    (timerValue - timerValue.toInt()).toStringAsFixed(2).substring(2),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "AzeretMono",
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
              LinearProgressIndicator(
                value: timerValue / Game.instance.levelTime,
                backgroundColor: Colors.blue.shade50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    setPuzzleTop(_game.puzzleTop(context));
    puzzleRotation = _game.puzzleRotation();

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const Background(),
          if (_game.showCountdown()) _buildCountdown(screenSize),
          if (_game.state == GameState.startScreen) ...[
            AnimatedButton(
              color: Colors.blue,
              height: 100,
              child: const Text(
                'Start',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onPressed: () {
                debugPrint("start pressed");
                setState(() {
                  _game.start((value) {
                    setState(() {
                      timerValue = value;
                    });
                  });
                  setPuzzleTop(_game.puzzleTop(context));
                });
              },
              enabled: true,
              shadowDegree: ShadowDegree.light,
            ),
          ],
          if (_game.state == GameState.playing)
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Needed for properly centering the puzzle. Stays in center
                  // during puzzle drop in/out phases
                  SizedBox(
                    width: _game.getPuzzleScreenSize(),
                    height: _game.getPuzzleScreenSize(),
                  ),
                  AnimatedPositioned(
                    duration: Duration(milliseconds: _game.isResetting() ? 0 : dropInAnimMs),
                    top: puzzleTop,
                    child: AnimatedRotation(
                      duration: const Duration(milliseconds: dropInAnimMs),
                      turns: puzzleRotation,
                      child: _game.puzzle != null
                          ? Grid(
                              _game.puzzle!,
                              (int number) async {
                                setState(() => _game.move(number));

                                if (_game.isSolved()) {
                                  await Future.delayed(Duration(milliseconds: (slideTimeMs * 0.7).toInt()));
                                  setState(() => _game.dropOut());

                                  await Future.delayed(const Duration(milliseconds: dropInAnimMs));
                                  setState(() => _game.reset());

                                  await Future.delayed(const Duration(milliseconds: resetMs));
                                  setState(() => _game.startLevel());

                                  await Future.delayed(const Duration(milliseconds: dropInAnimMs));
                                  setState(() => _game.puzzleState = PuzzleState.playing);
                                }
                              },
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
          if (_game.transitionStarted != null) ...[
            StateTransition((state) {
              setState(() {
                if (state == TransitionState.stateChange) {
                  _game.performTransition();
                }
              });
            }),
          ]
        ],
      ),
    );
  }
}
