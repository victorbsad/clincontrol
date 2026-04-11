import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_environment.dart';
import 'core/theme/app_theme.dart';
import 'data/database/database_config.dart';
import 'data/dev/development_seeder.dart';
import 'features/dashboard/screens/dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDatabaseFactory();
  if (AppEnvironment.devToolsEnabled) {
    try {
      await DevelopmentSeeder().seed();
    } catch (e, stackTrace) {
      debugPrint('Seed de desenvolvimento falhou: $e');
      debugPrint('$stackTrace');
    }
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinControl',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const Dashboard(),
    );
  }
}
