import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pushtrix/cubes.dart';
import 'package:pushtrix/game.dart';
import 'package:pushtrix/particle.dart';
import 'package:pushtrix/rays.dart';
import 'package:pushtrix/scene.dart';
import 'package:pushtrix/start_screen.dart';

import 'config.dart';
import 'game_time.dart';

class BackgroundPainter extends CustomPainter {
  final double value;
  Scene? scene;
  Scene? nextScene;
  BackgroundState state;

  BackgroundPainter({required this.value, required this.state, this.scene, this.nextScene}) {
    if (nextScene != null) debugPrint('BackgroundPainter $nextScene');
  }

/*
  void dummyPaint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final length = min(size.width, size.height);

    // Paint line moving up/down
    final range = size.height / 3;
    final y = size.height / 2 + sin(value) * range;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);

    // Paint center pulsing circle
    paint = Paint()
      ..color = Colors.blue.shade50
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final rMin = length * 0.4;
    final rMax = length * 0.45;
    canvas.drawCircle(Offset(center.dx, center.dy), rMin + (rMax - rMin) * sin(4 * value), paint);

    // Paint rotating circles
    paint = Paint()..color = Colors.blue.shade100;

    final r2 = length / 2;
    canvas.drawCircle(Offset(center.dx + r2 * cos(2 * value), center.dy + r2 * sin(2 * value)), 50, paint);

    paint = Paint()..color = Colors.blue.shade200;

    final r3 = length / 3;
    canvas.drawCircle(Offset(center.dx + r3 * cos(2 * value), center.dy + r3 * sin(2 * value)), 20, paint);
  }

  void paintPulsingCenter(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 50
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final length = min(size.width, size.height);

    paint = Paint()
      ..color = Colors.blue.shade50
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final rMin = length * 0.3;
    final rMax = length * 0.35;
    canvas.drawCircle(Offset(center.dx, center.dy), rMin + (rMax - rMin) * sin(4 * value), paint);
  }
  */

  @override
  void paint(Canvas canvas, Size size) {
    if (scene == null) {
      return;
    }

    if (nextScene != null) {
      nextScene!.render(canvas, size);
    }

    scene!.render(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class Background extends StatefulWidget {
  const Background({Key? key}) : super(key: key);

  @override
  State<Background> createState() => BackgroundState();
}

class BackgroundState extends State<Background> with TickerProviderStateMixin {
  late final AnimationController _controller;

  late final Ticker ticker;
  int frame = 0;

  static late BackgroundState instance;

  final _scenes = [
    Rays(),
    ParticleSystem(),
    Cubes(),
  ];

  final startScreen = StartScreen();

  int _currentSceneIndex = 0;

  BackgroundState() {
    BackgroundState.instance = this;

    if (useAnimationController) {
      _controller = AnimationController(
        duration: const Duration(seconds: 3600),
        upperBound: 3600,
        vsync: this,
      )..repeat();
    }

    ticker = Ticker((duration) {
      final current = duration.inMilliseconds / 1000.0;
      frame++;

      if (frame & 1 == 0) {
        final dt = current - GameTime.instance.current;
        GameTime.instance.tick(dt);

        _currentScene.tick();
        if (_currentScene.state == SceneState.fadeOut || _currentScene.state == SceneState.done) {
          final nextScene = _nextScene;
          if (nextScene != null) {
            nextScene.tick();
          }

          if (_currentScene.state == SceneState.done) {
            _currentScene.reset();
            _currentSceneIndex = (_currentSceneIndex + 1) % _scenes.length;
          }
        }

        setState(() {
          // debugPrint("setState");
        });
      }
    });

    ticker.start();
  }

  void pause() {
    ticker.stop();
  }

  void resume() {
    ticker.start();
  }

  Scene get _currentScene {
    if (Game.instance.state == GameState.startScreen) {
      return startScreen;
    } else {
      return _scenes[_currentSceneIndex];
    }
  }

  Scene? get _nextScene {
    return _scenes[(_currentSceneIndex + 1) % _scenes.length];
  }

  @override
  void dispose() {
    super.dispose();
    ticker.dispose();
    if (useAnimationController) {
      _controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final scene = _currentScene;
    final nextScene = _nextScene;
    final crossFade = _currentScene.state == SceneState.fadeOut;

    // if (crossFade) {
    //   debugPrint("$crossFade $nextScene");
    // }

    if (useAnimationController) {
      return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: BackgroundPainter(
                scene: scene,
                nextScene: crossFade ? nextScene : null,
                value: _controller.value,
                state: this,
              ),
              size: size,
            );
          });
    } else {
      return CustomPaint(
        size: size,
        painter: BackgroundPainter(
          value: GameTime.instance.current,
          state: this,
          scene: scene,
          nextScene: crossFade ? nextScene : null,
        ),
      );
    }
  }

  reset() {
    _currentSceneIndex = 0;
    for (final scene in _scenes) {
      scene.reset();
      scene.gameOver();
    }
  }

  // continue -> rays restart
}
