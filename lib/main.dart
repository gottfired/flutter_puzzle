import 'dart:async';
import 'dart:math';

import 'package:animated_button/animated_button.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pushtrix/app_lifecycle.dart';
import 'package:pushtrix/background.dart';
import 'package:pushtrix/countdown.dart';
import 'package:pushtrix/leaderboard.dart';
import 'package:pushtrix/leaderboard_dialog.dart';
import 'package:pushtrix/save_game.dart';
import 'package:pushtrix/state_transition.dart';

import 'audio.dart';
import 'audio_dialog.dart';
import 'config.dart';
import 'firebase_options.dart';
import 'game.dart';
import 'game_time.dart';
import 'grid.dart';
import 'highscore_dialog.dart';

Future<void> preAppInit() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final saveGame = SaveGame();
  await saveGame.init();
  GameTime.init();

  Audio.instance.init();
}

void main() async {
  await preAppInit();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushtrix',
      debugShowCheckedModeBanner: debugBanner,
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
  final AppLifecycle _appLifecycle = AppLifecycle(
    onResume: () {
      Game.instance.resume();
    },
    onPause: () {
      Game.instance.pause();
    },
  );

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
    Audio.instance.dispose();
    WidgetsBinding.instance.removeObserver(_appLifecycle);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(_appLifecycle);

    _game.setMainState(this);

    final soundEnabled = SaveGame.instance.soundEnabled;

    // Web doesn't allow autoplay of audio. Display dialog to allow user to enable audio.
    if (kIsWeb && soundEnabled && defaultTargetPlatform != TargetPlatform.iOS) {
      Future.delayed(const Duration(seconds: 0), () async {
        final enable = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => const AudioDialog(),
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

  void _showLeaderboard() async {
    await refreshLeaderboard();
    showDialog(
      context: context,
      builder: (BuildContext context) => const LeaderboardDialog(),
    );
  }

  void showHighscoreDialog(int rank, int score) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => HighScoreDialog(rank, score),
    );
  }

  @override
  Widget build(BuildContext context) {
    setPuzzleTop(_game.puzzleTop(context));
    puzzleRotation = _game.puzzleRotation();
    final mq = MediaQuery.of(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          const Background(),
          Countdown(_game),
          if (_game.state == GameState.startScreen) ...[
            buildStartButton(context),
            if (SaveGame.instance.maxLevel > 0 && SaveGame.instance.finishedOnce) ...[
              buildLevel("Your best ", context, true),
            ],
            Audio.instance.isIosWeb
                ? const SizedBox()
                : Positioned(
                    child: FloatingActionButton(
                      child: Icon(Audio.instance.settingEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                      onPressed: () {
                        setState(() {
                          Audio.instance.enable(!Audio.instance.settingEnabled);
                          SaveGame.instance.enableSound(Audio.instance.settingEnabled);
                          if (Audio.instance.settingEnabled) {
                            _showCredits();
                          } else {
                            _creditsShown = false;
                          }
                        });
                      },
                    ),
                    bottom: max(mq.padding.bottom, 16),
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
            Positioned(
              child: FloatingActionButton(
                child: const Icon(Icons.leaderboard_rounded),
                onPressed: _showLeaderboard,
              ),
              bottom: max(mq.padding.bottom, 16) + (Audio.instance.isIosWeb ? 0 : 80),
              right: 16,
            )
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
            buildLevel("Level ", context),
            // Positioned(top: 530, child: Text("  Loading ...", style: TextStyle(color: Colors.blue.shade800, fontSize: 40))),
          ],
          if (_game.transitionStarted != null) ...[
            StateTransition((state) async {
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

  Positioned buildLevel(String label, BuildContext context, [highscore = false]) {
    final mq = MediaQuery.of(context);

    final background = highscore ? Colors.red.shade700 : Colors.white;
    final color = highscore ? Colors.white : Colors.blue.shade600;
    const radius = Radius.circular(10);
    return Positioned(
      top: mq.padding.top,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.only(
            topLeft: mq.padding.top > 0 ? radius : Radius.zero,
            topRight: mq.padding.top > 0 ? radius : Radius.zero,
            bottomLeft: radius,
            bottomRight: radius,
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
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
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
