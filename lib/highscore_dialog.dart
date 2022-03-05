import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pushtrix/config.dart';
import 'package:pushtrix/leaderboard.dart';
import 'package:pushtrix/leaderboard_dialog.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class HighScoreDialog extends StatelessWidget {
  final int position;
  final int score;
  String name = "";

  HighScoreDialog(this.position, this.score, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 20, fontFamily: "AzeretMono");

    const range = 2;
    const first = 0;
    const last = leaderboardSize - 1;
    var start = position - range;
    var end = position + range;

    if (start < first) {
      final diff = -start;
      start = first;
      end += diff;
    } else if (end > last) {
      final diff = end - last;
      start -= diff;
      end = last;
    }

    List<Widget> entries = [];
    for (int i = start; i < position; i++) {
      final widget = LeaderboardEntryWidget(
        name: leaderboard[i].name,
        score: leaderboard[i].score,
        marginBottom: 8,
      );
      entries.add(widget);
    }

    final rankColor = getRankColor(getRank(score));
    final rankStyle = textStyle.copyWith(color: rankColor);
    entries.add(
      Container(
        width: 320,
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 32),
                child: TextField(
                  maxLength: 16,
                  style: rankStyle,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter Name',
                    counterText: '',
                    isCollapsed: true,
                    contentPadding: EdgeInsets.only(bottom: 8),
                  ),
                  onChanged: (value) {
                    name = value;
                  },
                ),
              ),
            ),
            Text(score > 0 ? "LVL ${getScoreString(score)}" : "-", style: rankStyle),
          ],
        ),
      ),
    );

    for (int i = position; i < end; i++) {
      final widget = LeaderboardEntryWidget(
        name: leaderboard[i].name,
        score: leaderboard[i].score,
        marginBottom: 8,
      );
      entries.add(widget);
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
                "New High Score!",
                style: textStyle.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 16),
              ...entries,
              const SizedBox(height: 32),
              buildSendButton(context),
            ],
          ),
        ),
      ),
    );
  }

  ElevatedButton buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await saveHighScore(name, score);
        Navigator.pop(context, true);
      },
      child: const Text("Send", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );
  }
}
