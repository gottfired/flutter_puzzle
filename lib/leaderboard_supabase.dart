import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:pushtrix/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LeaderboardEntry {
  String name = "";
  int score = 0;
}

List<LeaderboardEntry> leaderboard = [];
List<int> topScores = [];

Future<void> refreshLeaderboard([int newScore = 0]) async {
  leaderboard.clear();
  try {
    debugPrint("Refresh leaderboard");
    final data = await supabase.from("leaderboard").select("*").order("score").limit(leaderboardSize);
    // debugPrint("Data $data");

    for (final value in data) {
      LeaderboardEntry leaderboardEntry = LeaderboardEntry();
      leaderboardEntry.name = value['name'];
      leaderboardEntry.score = value['score'];
      leaderboard.add(leaderboardEntry);
    }
  } catch (error) {
    // TODO: Proper error handling
    debugPrint("Error refreshing leaderboard: $error");
  }

  // If leaderboard is not full -> fill up with "PUSHTRIX" entries
  if (leaderboard.length < leaderboardSize) {
    for (int i = leaderboard.length; i < leaderboardSize; i++) {
      LeaderboardEntry leaderboardEntry = LeaderboardEntry();
      leaderboardEntry.name = "PUSHTRIX";
      leaderboardEntry.score = 0;
      leaderboard.add(leaderboardEntry);
    }
  }

  List<int> scores = [];
  for (LeaderboardEntry entry in leaderboard) {
    scores.add(entry.score);
  }

  scores.add(newScore);

  topScores = scores.toSet().toList();
  topScores.sort((a, b) => b.compareTo(a));
}

String getScoreString(int score) {
  int top = topScores[0];
  int numDigits = top.toString().length;
  return score.toString().padLeft(numDigits, "0");
}

// Returns index in leaderboard or -1
Future<int> isHighScore(int score) async {
  await refreshLeaderboard(score);
  if (score <= leaderboard.last.score) {
    return -1;
  }

  for (int i = 0; i < leaderboard.length; i++) {
    if (leaderboard[i].score < score) {
      return i;
    }
  }

  return -1;
}

int getRank(int score) {
  for (int i = 0; i < topScores.length; ++i) {
    if (topScores[i] == score) {
      return i;
    }
  }

  return -1;
}

Future<void> saveHighScore(String name, int score) async {
  try {
    final data = await supabase.from("leaderboard").insert({
      "name": name,
      "score": score,
    });
  } catch (error) {
    // TODO: Proper error handling
    print("Error refreshing leaderboard: $error");
  }
}
