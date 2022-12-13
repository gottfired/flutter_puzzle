import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pushtrix/game_time.dart';
import 'package:pushtrix/lerp_value.dart';
import 'package:pushtrix/scenes/scene.dart';
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

final cubeFaces = [
  // back
  Vector4(0, 1, 2, 3),
  // front
  Vector4(7, 6, 5, 4),
  // sides
  Vector4(0, 4, 5, 1),
  Vector4(1, 5, 6, 2),
  Vector4(2, 6, 7, 3),
  Vector4(3, 7, 4, 0),
];

const numCubes = 9;
const start1 = 0;
const start3 = 1;
const start5 = 4;
const start7 = 7;
const start9 = 10;
const startFade = 8;
const fadeOut = 18;

class Cubes extends Scene {
  List<LerpValue> _lerpValues = [];

  double time = 0;
  final _backFaceFade = LerpValue(0);
  final _frontFaceFade = LerpValue(0);

  late final List<Vector4> _faceNormals = [];

  Cubes() {
    reset();
    for (final face in cubeFaces) {
      final v1 = cube[face[0].toInt()];
      final v2 = cube[face[1].toInt()];
      final v3 = cube[face[2].toInt()];

      final v1v2 = v2 - v1;
      final v1v3 = v3 - v1;

      final faceNormal = v1v2.xyz.cross(v1v3.xyz);
      faceNormal.normalize();
      debugPrint("faceNormal: $faceNormal");
      _faceNormals.add(Vector4(faceNormal.x, faceNormal.y, faceNormal.z, 0));
    }
  }

  void drawFace(Canvas canvas, Paint paint, List<Vector4> vertices, Vector4 face, double centerX, double centerY) {
    final v1 = vertices[face[0].toInt()];
    final v2 = vertices[face[1].toInt()];
    final v3 = vertices[face[2].toInt()];
    final v4 = vertices[face[3].toInt()];

    canvas.drawPath(
      Path()
        ..moveTo(v1.x * centerX / v1.w + centerX, v1.y * centerY / v1.w + centerY)
        ..lineTo(v2.x * centerX / v2.w + centerX, v2.y * centerY / v2.w + centerY)
        ..lineTo(v3.x * centerX / v3.w + centerX, v3.y * centerY / v3.w + centerY)
        ..lineTo(v4.x * centerX / v4.w + centerX, v4.y * centerY / v4.w + centerY)
        ..close(),
      paint,
    );
  }

  @override
  void render(Canvas canvas, Size size) {
    final rz = Matrix4.rotationZ(time * 1);
    final ry = Matrix4.rotationY(time * 0.0);
    final rx = Matrix4.rotationX(time * 4);

    final camPos = Vector3(0, 0, (sin(time * 2) + 1) * 3 + 2.0);
    final camUp = Vector3(cos(time), sin(time), 0);
    final view = makeViewMatrix(camPos, Vector3(0, 0, 0), camUp);

    // final rz = Matrix4.rotationZ(time * 0.0);
    // final ry = Matrix4.rotationY(time * 0.0);
    // final rx = Matrix4.rotationX(time * 0.0);

    // final camPos = Vector3(0, 0, 5);
    // final view = makeViewMatrix(Vector3(0, 0, 5), Vector3(0, 0, 0), Vector3(0, 1, 0));

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

        final pos = Vector3(
          (i - numCubes ~/ 2) * dist,
          (j - numCubes ~/ 2) * dist,
          -8 - value * 200,
        );
        final translation = Matrix4.translation(pos);

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 3.0;

        final mvp = vp * translation * rz * ry * rx;
        List<Vector4> out = [];
        for (final v in cube) {
          out.add(mvp.transformed(v));
        }

        final mv = view * rz * ry * rx;
        List<Vector4> outNormals = [];
        for (var i = 0; i < _faceNormals.length; i++) {
          outNormals.add(mv.transformed(_faceNormals[i]));
        }

        List<int> frontFaces = [];

        // Draw back faces
        paint.color = Color.lerp(const Color(0xffff0000), const Color(0x00ffffff), value + _backFaceFade.value)!;
        for (var i = 0; i < cubeFaces.length; i++) {
          final face = cubeFaces[i];
          final faceNormal = outNormals[i];

          final viewPos = view * (pos - camPos);
          final dot = viewPos.dot(faceNormal.xyz);
          if (dot < 0) {
            frontFaces.add(i);
            continue;
          }

          drawFace(canvas, paint, out, face, cx, cy);
        }

        // Draw front faces
        paint.color = Color.lerp(const Color(0xffff0000), const Color(0x00ffffff), value + _frontFaceFade.value)!;
        for (var i = 0; i < frontFaces.length; i++) {
          final face = cubeFaces[frontFaces[i]];
          drawFace(canvas, paint, out, face, cx, cy);
        }
      }
    }
  }

  @override
  void reset() {
    super.reset();
    time = 0;
    _backFaceFade.set(0);
    _frontFaceFade.set(0);
    _lerpValues = [];
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

    if (time > startFade) {
      _backFaceFade.lerpTo(0.7, 1.0);
      _backFaceFade.tick(dt);
    }

    if (time > fadeOut) {
      state = SceneState.fadeOut;
      _frontFaceFade.lerpTo(1.0, 1.0);
      _frontFaceFade.tick(dt);
      if (_frontFaceFade.value == 1.0) {
        state = SceneState.done;
      }
    }
  }
}
