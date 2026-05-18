import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError {
    if (!kIsWeb) {
      await Firebase.initializeApp();
    }
  } catch (_) {
    // Keep preview mode running if Firebase is not available on this platform.
  }

  SystemChrome.setSystemUIOverlayStyle(brandSystemUiOverlay);

  runApp(const MediQuickApp());
}

class MediQuickApp extends StatelessWidget {
  const MediQuickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediQuick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5FBFC),
        appBarTheme: brandAppBarTheme,
        useMaterial3: true,
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: brandSystemUiOverlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        OnboardingScreen.routeName: (_) => const OnboardingScreen(),
        AuthScreen.routeName: (_) => const AuthScreen(),
      },
      initialRoute: SplashScreen.routeName,
    );
  }
}

typedef MyApp = MediQuickApp;
