import 'package:flutter/material.dart';

class MusicCredits extends StatelessWidget {
  const MusicCredits({
    Key? key,
    required bool creditsShown,
  })  : _creditsShown = creditsShown,
        super(key: key);

  final bool _creditsShown;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: _creditsShown ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: const Text("Music by Bensound.com"),
      ),
    );
  }
}
