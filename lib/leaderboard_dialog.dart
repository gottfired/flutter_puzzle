import 'package:flutter/material.dart';
import 'package:pushtrix/leaderboard.dart';

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 20, fontFamily: "AzeretMono");

    int i = 1;
    final entries = leaderboard.map((e) {
      String index = i.toString().padLeft(2);
      i++;
      return LeaderboardEntry(rank: index, name: e.name, score: e.score);
    }).toList();

    if (entries.length < 20) {
      for (var i = entries.length; i < 20; ++i) {
        String index = (i + 1).toString().padLeft(2);
        entries.add(LeaderboardEntry(rank: index, name: "PUSHTRIX", score: 1));
      }
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "HIGH SCORES",
                style: textStyle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 16),
              buildContent(entries),
              const SizedBox(height: 32),
              buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Flexible buildContent(List<LeaderboardEntry> entries) {
    return Flexible(
      child: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              ...entries,
            ]),
          ),
        ),
      ),
    );
  }

  ElevatedButton buildCloseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context, true);
      },
      child: const Text("Close", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}

class LeaderboardEntry extends StatelessWidget {
  const LeaderboardEntry({
    Key? key,
    required this.rank,
    required this.name,
    required this.score,
  }) : super(key: key);

  final String rank;
  final String name;
  final int score;

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 20, fontFamily: "AzeretMono");
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$rank.${name.toUpperCase()}", style: textStyle),
          Text("LVL $score", style: textStyle),
        ],
      ),
    );
  }
}
