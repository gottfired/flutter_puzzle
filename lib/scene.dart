import 'package:flutter/rendering.dart';

enum SceneState {
  running,
  fadeOut,
  done,
}

abstract class Scene {
  void tick();
  void render(Canvas canvas, Size size);
  void reset();

  void gameOver() {
    // override if needed
  }

  SceneState state = SceneState.running;
}
