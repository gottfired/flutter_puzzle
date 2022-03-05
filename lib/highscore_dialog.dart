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
  final int rank;
  final int score;

  const HighScoreDialog(this.rank, this.score, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 20, fontFamily: "AzeretMono");

    final previousRank = rank.toString().padLeft(2);
    final nextRank = (rank + 2).toString().padLeft(2);

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
              if (rank > 0)
                LeaderboardEntryWidget(
                  rank: previousRank,
                  name: leaderboard[rank - 1].name,
                  score: leaderboard[rank - 1].score,
                  marginBottom: 8,
                ),
              Container(
                width: 320,
                margin: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("${(rank + 1).toString().padLeft(2)}.", style: textStyle),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, right: 16),
                        child: TextField(
                          maxLength: 10,
                          style: textStyle,
                          inputFormatters: [
                            UpperCaseTextFormatter(),
                          ],
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Enter Name',
                            counterText: '',
                            isCollapsed: true,
                            contentPadding: EdgeInsets.only(bottom: 8),
                          ),
                          onChanged: (value) {
                            //
                          },
                        ),
                      ),
                    ),
                    Text(score > 0 ? "LVL $score" : "-", style: textStyle),
                  ],
                ),
              ),
              if (rank < leaderboard.length - 1)
                LeaderboardEntryWidget(
                  rank: nextRank,
                  name: leaderboard[rank].name,
                  score: leaderboard[rank].score,
                ),
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
      onPressed: () {
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
