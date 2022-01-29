import 'dart:async';

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

  void setPuzzleTop(double? top) {
    // debugPrint("new top $top");
    puzzleTop = top;
  }

  @override
  Widget build(BuildContext context) {
    setPuzzleTop(_game.puzzleTop(context));
    puzzleRotation = _game.puzzleRotation();

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Background(),
          // const Countdown(seconds: 10),
          if (_game.state == GameState.startScreen)
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    _game.start();
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
                  Container(
                    width: _game.puzzle?.screenSize ?? 0,
                    height: _game.puzzle?.screenSize ?? 0,
                    // color: Colors.green,
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
                                        _game.solved();
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
