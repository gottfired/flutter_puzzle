import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame_audio/flame_audio.dart';
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

  bool settingEnabled = true;

  List<int> _praiseIndexes = [];
  int _currentPraise = 0;

  AudioPlayer? _player;
  Timer? _timer;

  bool isIosWeb = false;

  void init() {
    isIosWeb = kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS);

    if (!isIosWeb) {
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

    _praiseIndexes = List.generate(praises.length, (i) => i);
    _praiseIndexes.shuffle();
  }

  bool get _enabled => settingEnabled && !isIosWeb;

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

    if (_player != null) {
      await _player?.stop();
      _player = null;
    }

    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }

    _player = await FlameAudio.loop("music/bensound-scifi.mp3");
  }

  void gameMusic() async {
    if (!_enabled) return;

    if (_player != null) {
      await _player?.stop();
      _player = null;
    }
    _player = await FlameAudio.play("music/bensound-punky.mp3", volume: 0.4);

    if (kIsWeb) {
      // No streams on web -> use timer instead
      _timer = Timer(const Duration(seconds: 125), () {
        gameMusicFast();
        _timer = null;
      });
    } else {
      _player!.onPlayerCompletion.listen((onDone) {
        gameMusicFast();
      });
    }
  }

  void gameMusicFast() async {
    if (!_enabled) return;

    if (_player != null) {
      await _player?.stop();
      _player = null;
    }

    _player = await FlameAudio.loop("music/bensound-extremeaction.mp3", volume: 0.4);
  }

  void enable(bool enabled) async {
    settingEnabled = enabled;
    if (!enabled) {
      await _player?.stop();
      _player = null;
      _timer?.cancel();
    } else {
      menuMusic();
    }
  }
}
