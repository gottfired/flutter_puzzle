import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveGame {
  late final SharedPreferences _prefs;

  int maxLevel = 0;
  bool finishedOnce = false;

  static late final SaveGame instance;

  SaveGame() {
    SaveGame.instance = this;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    maxLevel = _prefs.getInt("maxLevel") ?? 0;
    finishedOnce = _prefs.getBool("finishedOnce") ?? false;
    debugPrint("### init maxLevel $maxLevel, finished $finishedOnce");
  }

  Future<void> saveLevel(int level) async {
    if (level > maxLevel) {
      maxLevel = level;
      await _prefs.setInt("maxLevel", level);
    }
  }

  Future<void> gameOver() async {
    finishedOnce = true;
    await _prefs.setBool("finishedOnce", true);
  }
}
