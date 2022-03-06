import 'package:flutter/material.dart';
import 'package:pushtrix/build_context_extension.dart';
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

TextStyle getLeaderboardTextStyle(BuildContext context) {
  return TextStyle(fontSize: context.isMobile() ? 18 : 20, fontFamily: "AzeretMono");
}

class LeaderboardDialog extends StatelessWidget {
  const LeaderboardDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final entries = leaderboard.map((e) {
      return LeaderboardEntryWidget(name: e.name, score: e.score);
    }).toList();

    final textStyle = getLeaderboardTextStyle(context);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.isMobile() ? 0 : 16, vertical: 24),
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
    final textStyle = getLeaderboardTextStyle(context).copyWith(color: color);

    return Container(
      width: 320,
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: Text(name.toUpperCase(), style: textStyle)),
          Text(score > 0 ? "LVL ${getScoreString(score)}" : "-", style: textStyle),
        ],
      ),
    );
  }
}
