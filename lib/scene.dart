import 'package:flutter/rendering.dart';

enum SceneState {
  running,
  fadeOut,
  done,
}

// Base class for background scenes
// A scene switches to the next one by entering
// the fadeOut and then done state. Once it is done
// the scene gets removed
abstract class Scene {
  void tick();
  void render(Canvas canvas, Size size);
  void reset() {
    state = SceneState.running;
  }

  void gameOver() {
    // override if needed
  }

  SceneState state = SceneState.running;
}
