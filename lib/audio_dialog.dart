import 'package:flutter/material.dart';

class AudioDialog extends StatelessWidget {
  const AudioDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 320), // TODO: Why is minWidth not working?
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  text: "La ",
                  style: const TextStyle(fontSize: 32, fontFamily: "Rowdies", fontWeight: FontWeight.w300, color: Colors.red),
                  children: <TextSpan>[
                    TextSpan(text: 'La ', style: TextStyle(color: Colors.yellow.shade600)),
                    const TextSpan(text: 'La ', style: TextStyle(color: Colors.blue)),
                    const TextSpan(text: 'or ', style: TextStyle(color: Colors.black)),
                    TextSpan(text: 'Hush?', style: TextStyle(color: Colors.grey.shade400)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  text: "This game was designed with audio in mind.\nYou decide: ",
                  style: const TextStyle(fontSize: 20, fontFamily: "Rowdies", fontWeight: FontWeight.w300, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: 'fun ', style: TextStyle(color: Colors.red.shade600)),
                    TextSpan(text: 'and ', style: TextStyle(color: Colors.yellow.shade800)),
                    TextSpan(text: 'funky ', style: TextStyle(color: Colors.blue.shade700)),
                    const TextSpan(text: 'or ', style: TextStyle(color: Colors.black)),
                    TextSpan(text: 'quiet and boring?', style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: const Text("Thank you for the music!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text("Shh, everyone's asleep.", style: TextStyle(fontSize: 18, color: Colors.grey.shade500)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
