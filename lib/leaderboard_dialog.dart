import 'package:flutter/material.dart';
import 'package:pushtrix/leaderboard.dart';

Color getRankColor(int rank) {
  if (rank == 0) {
    return Colors.red.shade600;
  } else if (rank == 1) {
    return Colors.yellow.shade800;
  } else if (rank == 2) {
    return Colors.blue.shade700;
  }

  return Colors.black;
}

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 20, fontFamily: "AzeretMono");

    final entries = leaderboard.map((e) {
      return LeaderboardEntryWidget(name: e.name, score: e.score);
    }).toList();

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

  Flexible buildContent(List<LeaderboardEntryWidget> entries) {
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

class LeaderboardEntryWidget extends StatelessWidget {
  const LeaderboardEntryWidget({
    Key? key,
    required this.name,
    required this.score,
    this.marginBottom = 4,
  }) : super(key: key);

  final String name;
  final int score;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    final color = getRankColor(getRank(score));

    final textStyle = TextStyle(fontSize: 20, fontFamily: "AzeretMono", color: color);

    return Container(
      width: 320,
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name.toUpperCase(), style: textStyle),
          Text(score > 0 ? "LVL ${getScoreString(score)}" : "-", style: textStyle),
        ],
      ),
    );
  }
}
