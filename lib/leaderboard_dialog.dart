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
      return Container(
        width: 320,
        margin: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("$index.${e.name.toUpperCase()}", style: textStyle),
            Text("LVL ${e.score}", style: textStyle),
          ],
        ),
      );
    }).toList();

    if (entries.length < 20) {
      for (var i = entries.length; i < 20; ++i) {
        String index = (i + 1).toString().padLeft(2);
        entries.add(Container(
          width: 320,
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$index.PUSHTRIX", style: textStyle),
              Text("-", style: textStyle),
            ],
          ),
        ));
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
              Flexible(
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
              ),
              const SizedBox(height: 32),
              ElevatedButton(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
