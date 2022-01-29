import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/background.dart';
import 'package:flutter_puzzle/countdown.dart';
import 'package:flutter_puzzle/puzzle.dart';

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
        // This is the theme of your application.
        primarySwatch: Colors.blue,
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

  @override
  Widget build(BuildContext context) {
    setPuzzleTop(_game.puzzleTop(context));
    puzzleRotation = _game.puzzleRotation();

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Background(),
          if (_game.showCountdown())
            Positioned(
                top: screenSize.height / 2 - _game.getPuzzleScreenSize() / 2 - 50,
                child: Row(
                  children: [
                    Text(
                      timerValue.toInt().toString(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      (timerValue - timerValue.toInt()).toStringAsFixed(2).substring(2),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                )),
          if (_game.state == GameState.startScreen || _game.state == GameState.gameOver)
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _game.start((value) {
                      setState(() {
                        timerValue = value;
                      });
                    });
                    setPuzzleTop(_game.puzzleTop(context));
                  });
                },
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(200, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100.0),
                    )),
                child: const Text("Start",
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                    ))),
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
                              (int number) {
                                setState(() {
                                  _game.move(number);
                                  if (_game.isSolved()) {
                                    // debugPrint("### dropOut");
                                    // Drop out
                                    setPuzzleTop(_game.puzzleTop(context));
                                    puzzleRotation = _game.puzzleRotation();

                                    // Reset after drop out
                                    Timer(const Duration(milliseconds: dropInAnimMs), () {
                                      setState(() {
                                        // debugPrint("### reset");
                                        _game.reset();
                                        setPuzzleTop(_game.puzzleTop(context));
                                        puzzleRotation = _game.puzzleRotation();
                                      });
                                    });

                                    // Drop in
                                    Timer(const Duration(milliseconds: dropInAnimMs + resetMs), () {
                                      setState(() {
                                        // debugPrint("### dropIn");
                                        _game.startLevel();
                                        setPuzzleTop(_game.puzzleTop(context));
                                        puzzleRotation = _game.puzzleRotation();
                                      });
                                    });

                                    // Finish drop in
                                    Timer(const Duration(milliseconds: 2 * dropInAnimMs + resetMs), () {
                                      setState(() {
                                        // debugPrint("### dropInFinished");
                                        _game.dropIn = false;
                                        setPuzzleTop(_game.puzzleTop(context));
                                        puzzleRotation = _game.puzzleRotation();
                                      });
                                    });
                                  }
                                });
                              },
                            )
                          : const SizedBox(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
