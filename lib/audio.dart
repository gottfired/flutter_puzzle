import 'dart:async';
import 'dart:math';

import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

const praises = [
  "sounds/well_done.mp3",
  "sounds/great.mp3",
  "sounds/keep_it_up.mp3",
  "sounds/excellent.mp3",
  "sounds/awesome.mp3",
];

class Audio {
  static final Audio instance = Audio();

  int lastPraise = -1;

  AudioPlayer? player;
  Timer? timer;

  void init() {
    FlameAudio.audioCache.loadAll([
      "sounds/swish.wav",
      "sounds/click.wav",
      ...praises,
      "sounds/game_over.mp3",
      "sounds/too_easy.mp3",
      "sounds/that_was_close.mp3",
      "sounds/beep.mp3",
      "sounds/beep_long.mp3",
      "music/bensound-scifi.mp3",
      "music/bensound-punky.mp3",
    ]);
  }

  void click() {
    FlameAudio.play("sounds/click.wav");
  }

  void swish() {
    FlameAudio.play("sounds/swish.wav", volume: 0.5);
  }

  void praise() {
    int nextPraise = 0;
    while (nextPraise == lastPraise) {
      nextPraise = Random().nextInt(praises.length);
    }

    FlameAudio.play(praises[nextPraise]);
    lastPraise = nextPraise;
  }

  void thatWasClose() {
    FlameAudio.play("sounds/that_was_close.mp3");
  }

  void gameOver() {
    FlameAudio.play("sounds/game_over.mp3");
  }

  void tooEasy() {
    FlameAudio.play("sounds/too_easy.mp3");
  }

  void beep() {
    FlameAudio.play("sounds/beep.mp3");
  }

  void beepLong() {
    FlameAudio.play("sounds/beep_long.mp3");
  }

  void menuMusic() async {
    if (player != null) {
      await player?.stop();
      player = null;
    }

    if (timer != null) {
      timer!.cancel();
      timer = null;
    }

    player = await FlameAudio.loop("music/bensound-scifi.mp3");
  }

  void gameMusic() async {
    if (player != null) {
      await player?.stop();
      player = null;
    }
    player = await FlameAudio.play("music/bensound-punky.mp3", volume: 0.4);

    if (kIsWeb) {
      // No streams on web -> use timer instead
      timer = Timer(const Duration(seconds: 125), () {
        gameMusicFast();
        timer = null;
      });
    } else {
      player!.onPlayerCompletion.listen((onDone) {
        gameMusicFast();
      });
    }
  }

  void gameMusicFast() async {
    if (player != null) {
      await player?.stop();
      player = null;
    }

    player = await FlameAudio.loop("music/bensound-extremeaction.mp3", volume: 0.4);
  }
}
