import 'package:flutter/rendering.dart';

abstract class Scene {
  void tick();
  void render(Canvas canvas, Size size);
}
