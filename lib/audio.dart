import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:pushtrix/config.dart';

const praises = [
  "sounds/well_done.mp3",
  "sounds/great.mp3",
  "sounds/keep_it_up.mp3",
  "sounds/excellent.mp3",
  "sounds/awesome.mp3",
];

class Audio {
  static final Audio instance = Audio();

  bool settingEnabled = true;

  List<int> _praiseIndexes = [];
  int _currentPraise = 0;

  AudioPlayer? _player;
  Timer? _timer;

  bool isIosWebDisabled = false;

  void init() {
    isIosWebDisabled = kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && !enableIosWebAudio;

    if (!isIosWebDisabled) {
      FlameAudio.audioCache.loadAll([
        "sounds/swish.wav",
        "sounds/click.wav",
        ...praises,
        "sounds/game_over.mp3",
        "sounds/too_easy.mp3",
        "sounds/that_was_close.mp3",
        "sounds/beep.mp3",
        "sounds/beep_long.mp3",
      ]);

      FlameAudio.bgm.initialize();
      FlameAudio.audioCache.loadAll(["music/bensound-scifi.mp3", "music/bensound-punky.mp3"]);
    }

    _praiseIndexes = List.generate(praises.length, (i) => i);
    _praiseIndexes.shuffle();
  }

  void dispose() {
    if (!isIosWebDisabled) {
      FlameAudio.bgm.dispose();
    }
  }

  bool get _enabled => settingEnabled && !isIosWebDisabled;

  void click() {
    if (!_enabled) return;

    FlameAudio.play("sounds/click.wav");
  }

  void swish() {
    if (!_enabled) return;

    FlameAudio.play("sounds/swish.wav", volume: 0.5);
  }

  void praise() {
    if (!_enabled) return;

    FlameAudio.play(praises[_praiseIndexes[_currentPraise++]]);
    if (_currentPraise >= praises.length) {
      _currentPraise = 0;
      _praiseIndexes.shuffle();
    }
  }

  void thatWasClose() {
    if (!_enabled) return;

    FlameAudio.play("sounds/that_was_close.mp3");
  }

  void gameOver() {
    if (!_enabled) return;

    FlameAudio.play("sounds/game_over.mp3");
  }

  void tooEasy() {
    if (!_enabled) return;

    FlameAudio.play("sounds/too_easy.mp3");
  }

  void beep() {
    if (!_enabled) return;
    FlameAudio.play("sounds/beep.mp3");
  }

  void beepLong() {
    if (!_enabled) return;

    FlameAudio.play("sounds/beep_long.mp3");
  }

  void menuMusic() async {
    if (!_enabled) return;

    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    FlameAudio.bgm.play("music/bensound-scifi.mp3");
  }

  void gameMusic() async {
    if (!_enabled) return;

    FlameAudio.bgm.play("music/bensound-punky.mp3", volume: 0.4);

    // TODO: Fix timer starting fast music when app in background
    // _timer = Timer(const Duration(seconds: 125), () {
    //   gameMusicFast();
    //   _timer = null;
    // });
  }

  void gameMusicFast() async {
    if (!_enabled) return;

    FlameAudio.bgm.play("music/bensound-extremeaction.mp3", volume: 0.4);
  }

  void enable(bool enabled) async {
    settingEnabled = enabled;
    if (!enabled) {
      FlameAudio.bgm.stop();
      await _player?.stop();
      _player = null;
      _timer?.cancel();
    } else {
      menuMusic();
    }
  }
}
