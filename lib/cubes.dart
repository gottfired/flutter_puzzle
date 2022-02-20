import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_puzzle/game_time.dart';
import 'package:flutter_puzzle/lerp_value.dart';
import 'package:flutter_puzzle/scene.dart';
import 'package:vector_math/vector_math_64.dart';

final cube = [
  // Back face
  Vector4(1, 1, -1, 1),
  Vector4(1, -1, -1, 1),
  Vector4(-1, -1, -1, 1),
  Vector4(-1, 1, -1, 1),

  // Front face
  Vector4(1, 1, 1, 1),
  Vector4(1, -1, 1, 1),
  Vector4(-1, -1, 1, 1),
  Vector4(-1, 1, 1, 1),
];

final cubeEdges = [
  // back
  Vector2(0, 1),
  Vector2(1, 2),
  Vector2(2, 3),
  Vector2(3, 0),
  // front
  Vector2(4, 5),
  Vector2(5, 6),
  Vector2(6, 7),
  Vector2(7, 4),
  // sides
  Vector2(0, 4),
  Vector2(1, 5),
  Vector2(2, 6),
  Vector2(3, 7),
];

const numCubes = 9;
const start1 = 0;
const start3 = 1;
const start5 = 4;
const start7 = 7;
const start9 = 10;

class Cubes extends Scene {
  List<LerpValue> _lerpValues = [];

  double time = 0;
  bool started3 = false;
  bool started5 = false;
  bool started7 = false;
  bool started9 = false;

  Cubes() {
    reset();
  }

  @override
  void render(Canvas canvas, Size size) {
    final rz = Matrix4.rotationZ(time * 1);
    final ry = Matrix4.rotationY(time * 0.0);
    final rx = Matrix4.rotationX(time * 4);

    final view = makeViewMatrix(Vector3(0, 0, (sin(time * 2) + 1) * 3 + 2.0), Vector3(0, 0, 0), Vector3(cos(time), sin(time), 0));
    final projection = makePerspectiveMatrix(pi / 3, size.width / size.height, 0.1, 100);
    final vp = projection * view;

    // calculate center
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint = Paint()..strokeWidth = 4.0;

    const dist = 3.5;

    for (var i = 0; i < numCubes; i++) {
      for (var j = 0; j < numCubes; j++) {
        final value = _lerpValues[i * numCubes + j].value;

        final translation = Matrix4.translation(
          Vector3(
            (i - numCubes ~/ 2) * dist,
            (j - numCubes ~/ 2) * dist,
            -8 - value * 200,
          ),
        );

        paint.color = Color.lerp(const Color(0xffff0000), const Color(0x00ffffff), value)!;

        final mvp = vp * translation * rz * ry * rx;
        List<Vector4> out = [];
        for (final v in cube) {
          out.add(mvp.transformed(v));
        }

        for (final edge in cubeEdges) {
          final v1 = out[edge.x.toInt()];
          final v2 = out[edge.y.toInt()];

          canvas.drawLine(
            Offset(v1.x * cx / v1.w + cx, v1.y * cy / v1.w + cy),
            Offset(v2.x * cx / v2.w + cx, v2.y * cy / v2.w + cy),
            paint,
          );
        }
      }
    }
  }

  @override
  void reset() {
    time = 0;
    for (int i = 0; i < numCubes * numCubes; i++) {
      _lerpValues.add(LerpValue(1.0));
    }
  }

  @override
  void tick() {
    final dt = GameTime.instance.dt;
    time += dt;

    const mid = numCubes ~/ 2;
    bool isInRange(i, j, r) => (i >= mid - r && i <= mid + r) && (j >= mid - r && j <= mid + r);
    bool is1(int i, int j) => i == mid && j == mid;
    bool is3(int i, int j) => !is1(i, j) && isInRange(i, j, 1);
    bool is5(int i, int j) => !is3(i, j) && isInRange(i, j, 2);
    bool is7(int i, int j) => !is5(i, j) && isInRange(i, j, 3);
    bool is9(int i, int j) => !is7(i, j) && isInRange(i, j, 4);

    final st = sin(time);
    for (int i = 0; i < numCubes; i++) {
      for (int j = 0; j < numCubes; j++) {
        final index = i * numCubes + j;
        _lerpValues[index].tick(dt);
        if ((time > start1 && is1(i, j)) ||
            (time > start3 && is3(i, j)) ||
            (time > start5 && is5(i, j)) ||
            (time > start7 && is7(i, j)) ||
            (time > start9 && is9(i, j))) {
          _lerpValues[index].lerpTo(0.0, 1.0);
        }
      }
    }
  }
}
