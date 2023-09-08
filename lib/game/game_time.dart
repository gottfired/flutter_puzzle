class GameTime {
  static late GameTime instance;

  static void init() {
    GameTime.instance = GameTime();
  }

  double current = 0;
  double dt = 0;

  void tick(double delta) {
    if (delta < 0) {
      return;
    }

    current += delta;
    dt = delta;
  }
}
