# VitaTree

VitaTree is a Flutter mobile health monitoring app where a living tree reflects the user's composite health score.

## Features

- Interactive 10-level tree on the home screen with PNG assets and a fallback `CustomPainter`.
- Composite health score from sleep, daily quests, mood, and activity.
- Daily stress-relief quests with countdown timer, streaks, and score updates.
- Sleep tracking with time pickers, duration scoring, 7-day `fl_chart` bar chart, and notification preview.
- Statistics screen with radar chart, 30-day heatmap, period toggle, and trend cards.
- Reflection flow triggered by sustained high scores, with confetti and a local journal.

## Tech Stack

- Flutter 3.x / Dart 3.x
- Riverpod `StateNotifier`
- Hive local storage
- GoRouter `ShellRoute`
- FL Chart
- Google Fonts Nunito
- Flutter local notifications

## Firebase Setup

This app uses Firebase Auth and Realtime Database through the Firebase project
`healtcare-dd7ea`.

Firebase configuration is generated in `lib/firebase_options.dart` with the
FlutterFire CLI for Android, iOS, and Web. Run the app normally:

```powershell
flutter run
```

To regenerate Firebase configuration after changing Firebase projects or app
IDs:

```powershell
firebase.cmd login:use rodiyanramadhani73@gmail.com
flutterfire.bat configure --project=healtcare-dd7ea
```

Tree PNGs should be placed in `assets/trees/` as `tree_lv1.png` through `tree_lv10.png`.
