import 'package:flutter/material.dart';
import 'package:flutter_puzzle/background.dart';
import 'package:flutter_puzzle/countdown.dart';
import 'package:flutter_puzzle/puzzle.dart';

import 'game.dart';
import 'grid.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pushtrix',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(title: 'Pushtrix'),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _game = Game();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: Stack(children: [
        Background(),
        Center(
          child: Column(
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // const Countdown(seconds: 10),
              if (_game.state == GameState.startScreen)
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _game.start();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 100),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        )),
                    child: const Text("Start",
                        style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                        ))),
              if (_game.state == GameState.playing)
                Grid(_game.puzzle!, (int number) {
                  setState(() {
                    _game.move(number);
                  });
                })
            ],
          ),
        ),
      ]),
    );
  }
}
