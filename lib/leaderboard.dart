import 'package:firebase_database/firebase_database.dart';
import 'package:pushtrix/config.dart';

class LeaderboardEntry {
  String name = "";
  int score = 0;
}

List<LeaderboardEntry> leaderboard = [];

Future<void> refreshLeaderboard() async {
  leaderboard.clear();
  final event = await FirebaseDatabase.instance.ref('highScores').orderByChild("score").limitToLast(leaderboardSize).once();
  if (event.snapshot.value != null) {
    final data = event.snapshot.children;
    for (final entry in data) {
      Map<String, dynamic> value = entry.value as Map<String, dynamic>;
      LeaderboardEntry leaderboardEntry = LeaderboardEntry();
      leaderboardEntry.name = value['name'];
      leaderboardEntry.score = value['score'];
      leaderboard.add(leaderboardEntry);
    }

    // Sort descending
    leaderboard.sort((a, b) => b.score.compareTo(a.score));
  }

  if (leaderboard.length < leaderboardSize) {
    for (int i = leaderboard.length; i < leaderboardSize; i++) {
      LeaderboardEntry leaderboardEntry = LeaderboardEntry();
      leaderboardEntry.name = "PUSHTRIX";
      leaderboardEntry.score = 0;
      leaderboard.add(leaderboardEntry);
    }
  }
}

// Returns index in leaderboard or -1
Future<int> isHighScore(int score) async {
  await refreshLeaderboard();
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

Future<void> saveHighScore(String name, int score) async {
  final ref = FirebaseDatabase.instance.ref('highScores').push();
  await ref.set({
    'name': name,
    'score': score,
  });
}
