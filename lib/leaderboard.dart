import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:eval_ex/expression.dart';
import 'package:flutter/foundation.dart';
import 'package:pushtrix/config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

final supabase = Supabase.instance.client;

class LeaderboardEntry {
  String name = "";
  int score = 0;
}

List<LeaderboardEntry> leaderboard = [];
List<int> topScores = [];

String scoreToHash(String name, int score, double salt) {
  final lower = name.toLowerCase();
  var saltedScore = utf8.encode("$lower$score${Env.HASH}$salt");
  final hash = sha256.convert(saltedScore).toString();

  return hash;
}

int scoreFromHash(String name, String hash, double salt) {
  final lower = name.toLowerCase();

  // reverse hash
  for (int i = 0; i < 1000; ++i) {
    var saltedScore = utf8.encode("$lower$i${Env.HASH}$salt");
    final value = sha256.convert(saltedScore).toString();
    if (value == hash) {
      return i;
    }
  }

  return -1;
}

Future<void> refreshLeaderboard([int newScore = 0]) async {
  leaderboard.clear();
  try {
    debugPrint("Refresh leaderboard");
    final data = await supabase
            .from("leaderboard")
            .select("id,name,salt,hash")
            .order("salt", ascending: true)
            .order("created_at")
            .order("hash")
            .limit(leaderboardSize + 10) // +10 to add some buffer for illegal score entries
        ;

    for (int i = 0; i < leaderboardSize; ++i) {
      final value = data[i];
      final name = value['name'];
      final salt = value["salt"];
      final hash = value['hash'];
      final score = hash != null ? scoreFromHash(name, hash, salt) : -1;
      final scoreValid = score >= 0;
      if (scoreValid) {
        LeaderboardEntry leaderboardEntry = LeaderboardEntry();
        leaderboardEntry.name = name;
        leaderboardEntry.score = score;
        leaderboard.add(leaderboardEntry);
      } else {
        // Delete invalid entry
        await supabase.from("leaderboard").delete().eq("id", value["id"]);
      }
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
    final salt = Expression(Env.SALT).setStringVariable("x", score.toString()).eval()?.toDouble() ?? 0.0;
    await supabase.from("leaderboard").insert({
      "name": name.toUpperCase(),
      "salt": salt,
      "hash": scoreToHash(name, score, salt),
    });
  } catch (error) {
    // TODO: Proper error handling
    print("Error refreshing leaderboard: $error");
  }
}
