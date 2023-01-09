# Pushtrix

A fast paced puzzle game.

Try it out at https://gottfired.github.io/pushtrix

This app still has a few issues (mainly when build for iOS/Android native - see TODO.md).

Won Runner Up in category multiplatform in the Flutter Puzzle Hack: https://flutterhack.devpost.com/

# How to build

-   `flutter pub get`
-   make a copy of `.env.empty` and name it `.env`
-   `flutter pub run build_runner build --delete-conflicting-outputs`
-   `flutter run`
-   Leaderboard will not work when buildding the game this way, since the keys needed for hashing highscore entries are not part of this repo. This method for encrypting the leaderboard is not secure at all but at least provides some basic obfuscation to prevent casual cheaters from entering bogus scores. I deliberately didn't want to lock highscore entries behind a login to keep the old school arcade feel. So if you figure out how to enter a highscore without playing, congrats you're a 1337 h4x0r! But please don't ruin the game for others.

# Known Issues

-   Uploading an iOS build triggers a warning email regarding push notifications that can be ignored: https://stackoverflow.com/a/55167613/677910
