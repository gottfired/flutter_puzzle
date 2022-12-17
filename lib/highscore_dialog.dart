import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pushtrix/build_context_extension.dart';
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

class HighScoreDialog extends StatefulWidget {
  final int position;
  final int score;

  HighScoreDialog(this.position, this.score, {Key? key}) : super(key: key);

  @override
  State<HighScoreDialog> createState() => _HighScoreDialogState();
}

class _HighScoreDialogState extends State<HighScoreDialog> {
  String name = "";
  bool sendEnabled = false;

  void send() async {
    await saveHighScore(name, widget.score);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = getLeaderboardTextStyle(context);

    const range = 2;
    const first = 0;
    const last = leaderboardSize - 1;
    var start = widget.position - range;
    var end = widget.position + range;

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
    for (int i = start; i < widget.position; i++) {
      final widget = LeaderboardEntryWidget(
        name: leaderboard[i].name,
        score: leaderboard[i].score,
        marginBottom: 8,
      );
      entries.add(widget);
    }

    final rankColor = getRankColor(getRank(widget.score));
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
                  maxLength: 14,
                  style: rankStyle,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp("[ ]")),
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
                    setState(() {
                      name.isNotEmpty ? sendEnabled = true : sendEnabled = false;
                    });
                  },
                  onEditingComplete: name.isNotEmpty ? send : null,
                ),
              ),
            ),
            Text(widget.score > 0 ? "LVL ${getScoreString(widget.score)}" : "-", style: rankStyle),
          ],
        ),
      ),
    );

    for (int i = widget.position; i < end; i++) {
      final widget = LeaderboardEntryWidget(
        name: leaderboard[i].name,
        score: leaderboard[i].score,
        marginBottom: 8,
      );
      entries.add(widget);
    }

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: context.isMobile() ? 16 : 32, vertical: 24),
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
        ),
      ),
    );
  }

  ElevatedButton buildSendButton(BuildContext context) {
    return ElevatedButton(
      onPressed: sendEnabled ? send : null,
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
