import 'dart:async';

import 'package:animated_button/animated_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_puzzle/background.dart';
import 'package:flutter_puzzle/countdown.dart';
import 'package:flutter_puzzle/save_game.dart';
import 'package:flutter_puzzle/state_transition.dart';

import 'audio.dart';
import 'audio_dialog.dart';
import 'config.dart';
import 'game.dart';
import 'game_time.dart';
import 'grid.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final saveGame = SaveGame();
  await saveGame.init();
  GameTime.init();

  Audio.instance.init();

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
        backgroundColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
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
  bool _creditsShown = false;
  Timer? _creditsTimer;

  void setPuzzleTop(double? top) {
    // debugPrint("new top $top");
    puzzleTop = top;
  }

  void redraw() {
    setState(() {});
  }

  @override
  void dispose() {
    _creditsTimer?.cancel();
    _creditsTimer = null;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _game.setMainState(this);

    final soundEnabled = SaveGame.instance.soundEnabled;

    // Web doesn't allow autoplay of audio. Display dialog to allow user to enable audio.
    if (kIsWeb && soundEnabled) {
      Future.delayed(const Duration(seconds: 0), () async {
        final enable = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AudioDialog();
          },
        );

        setState(() {
          if (enable) {
            Audio.instance.enable(true);
            SaveGame.instance.enableSound(true);
            _showCredits();
          } else {
            Audio.instance.enable(false);
            SaveGame.instance.enableSound(false);
          }
        });
      });
    } else {
      Audio.instance.enable(soundEnabled);
      if (soundEnabled) {
        _showCredits();
      }
    }
  }

  void _showCredits() {
    setState(() {
      _creditsShown = true;
    });

    if (_creditsTimer != null) {
      _creditsTimer!.cancel();
    }

    // Hide after 2 seconds
    _creditsTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _creditsShown = false;
      });
    });
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
            if (SaveGame.instance.maxLevel > 0 && SaveGame.instance.finishedOnce) ...[
              buildLevel("Highscore ", true),
            ],
            Positioned(
              child: FloatingActionButton(
                child: Icon(Audio.instance.enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                onPressed: () {
                  setState(() {
                    Audio.instance.enable(!Audio.instance.enabled);
                    SaveGame.instance.enableSound(Audio.instance.enabled);
                    if (Audio.instance.enabled) {
                      _showCredits();
                    } else {
                      _creditsShown = false;
                    }
                  });
                },
              ),
              bottom: 16,
              right: 16,
            ),
            Positioned(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: _creditsShown ? 1 : 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: const Text("Music by Bensound.com"),
                ),
              ),
              bottom: 16,
            ),
          ],
          if (_game.state == GameState.playing) ...[
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
            buildLevel("Level "),
            // Positioned(top: 530, child: Text("  Loading ...", style: TextStyle(color: Colors.blue.shade800, fontSize: 40))),
          ],
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

  Positioned buildLevel(String label, [highscore = false]) {
    final background = highscore ? Colors.red.shade700 : Colors.white;
    final color = highscore ? Colors.white : Colors.blue.shade600;
    return Positioned(
      top: 0,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade400.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 6,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 20, color: color),
              ),
              Text(
                "${highscore ? SaveGame.instance.maxLevel : _game.currentLevel}",
                style: TextStyle(fontFamily: "AzeretMono", fontWeight: FontWeight.bold, fontSize: 24, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector buildStartButton(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        Audio.instance.click();
      },
      child: AnimatedButton(
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
      ),
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
                onTap: (int number) async {
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
