import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_application_2/main.dart';
import 'package:flutter_application_2/features/auth/providers/auth_provider.dart';

class FakeUser implements User {
  @override
  String get displayName => 'Alya';

  @override
  String get email => 'alya@example.com';

  @override
  String get uid => 'mock_uid_123';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(AuthState state) : super() {
    this.state = state;
  }
}

void main() {
  late Directory hiveDir;

  setUpAll(() async {
    setupFirebaseCoreMocks();
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    GoogleFonts.config.allowRuntimeFetching = false;
    hiveDir = Directory.systemTemp.createTempSync('vitatree_test_hive');
    Hive.init(hiveDir.path);
    await initializeDateFormatting('id', null);
  });

  tearDownAll(() async {
    await Hive.close();
    if (hiveDir.existsSync()) {
      hiveDir.deleteSync(recursive: true);
    }
  });

  testWidgets('VitaTree renders home screen', (tester) async {
    final fakeUser = FakeUser();
    final mockAuthNotifier = MockAuthNotifier(AuthState(user: fakeUser));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) => mockAuthNotifier),
        ],
        child: const VitaTreeApp(),
      ),
    );

    // Pump frames to allow the router and home screen to render
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Hi, Alya'), findsOneWidget);
    expect(find.text('Your Health Tree'), findsOneWidget);
    expect(find.text('Pohon'), findsOneWidget);
  });
}
