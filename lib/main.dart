import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'firebase_options.dart';
import 'services/firebase_database_service.dart';
import 'services/notification_service.dart';
import 'shared/widgets/mascot_loading.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: VitaTreeBootstrap(startup: _initializeApp())));
}

Future<void> _initializeApp() async {
  await Hive.initFlutter();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseDatabaseService.instance.initialize();
  await NotificationService.instance.initialize();
  await initializeDateFormatting('id', null);
}

class VitaTreeBootstrap extends StatelessWidget {
  const VitaTreeBootstrap({super.key, required this.startup});

  final Future<void> startup;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError) {
          return const VitaTreeApp();
        }

        return MaterialApp(
          title: 'VitaTree',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: MascotLoadingScreen(
            message: snapshot.hasError
                ? snapshot.error.toString()
                : 'Preparing your health garden',
          ),
        );
      },
    );
  }
}

class VitaTreeApp extends ConsumerWidget {
  const VitaTreeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'VitaTree',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
