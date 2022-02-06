import 'dart:async';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_puzzle/background.dart';
import 'package:flutter_puzzle/countdown.dart';
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
  State<MainPage> createState() => MainState();
}

class MainState extends State<MainPage> {
  final _game = Game();
  double? puzzleTop = 0;
  double puzzleRotation = 0;
  double timerValue = 0;

  void setPuzzleTop(double? top) {
    // debugPrint("new top $top");
    puzzleTop = top;
  }

  void redraw() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _game.setMainState(this);
  }

  @override
  Widget build(BuildContext context) {
    setPuzzleTop(_game.puzzleTop(context));
    puzzleRotation = _game.puzzleRotation();

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const Background(),
          Countdown(_game),
          if (_game.state == GameState.startScreen) ...[
            buildStartButton(context),
          ],
          if (_game.state == GameState.playing)
            Center(
              child: Stack(
                clipBehavior: Clip.none, // So that the puzzle doesn't clip during drop in/out anims
                children: [
                  // Needed for properly centering the puzzle. Stays in center
                  // during puzzle drop in/out phases
                  SizedBox(
                    width: _game.getPuzzleScreenSize(),
                    height: _game.getPuzzleScreenSize(),
                  ),
                  buildPuzzle(),
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

  AnimatedButton buildStartButton(BuildContext context) {
    return AnimatedButton(
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
          _game.start();
          setPuzzleTop(_game.puzzleTop(context));
        });
      },
      enabled: true,
      shadowDegree: ShadowDegree.light,
    );
  }

  AnimatedPositioned buildPuzzle() {
    return AnimatedPositioned(
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
    );
  }
}
