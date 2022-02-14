import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveGame {
  late final SharedPreferences _prefs;

  int maxLevel = 0;
  bool finishedOnce = false;
  bool soundEnabled = true;

  static late final SaveGame instance;

  SaveGame() {
    SaveGame.instance = this;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    maxLevel = _prefs.getInt("maxLevel") ?? 0;
    finishedOnce = _prefs.getBool("finishedOnce") ?? false;
    soundEnabled = _prefs.getBool("soundEnabled") ?? true;
    debugPrint("load sound: $soundEnabled");
  }

  Future<void> saveLevel(int level) async {
    if (level > maxLevel) {
      maxLevel = level;
      await _prefs.setInt("maxLevel", level);
    }
  }

  Future<void> enableSound(bool enabled) async {
    soundEnabled = enabled;
    debugPrint("save sound: $enabled");
    await _prefs.setBool("soundEnabled", enabled);
  }

  Future<void> gameOver() async {
    finishedOnce = true;
    await _prefs.setBool("finishedOnce", true);
  }
}
