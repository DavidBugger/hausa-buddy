import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemChrome if you re-add it
import 'package:learn_hausa/screens/auth/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'models/auth_state.dart';
import 'screens/auth/sign_in_screen.dart'; // <--- IMPORT SignInScreen

// Firebase and Crashlytics imports (Add these back when you're ready)
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart' show kDebugMode, PlatformDispatcher;
// import 'firebase_options.dart';

void main() async { // Make async if you add Firebase.initializeApp
  // WidgetsFlutterBinding.ensureInitialized(); // Needed for Firebase.initializeApp and SystemChrome

  // --- Re-add Firebase and Crashlytics Setup Here When Ready ---
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // if (kDebugMode) {
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
  // } else {
  //   await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // }
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
  // --- End Firebase Setup ---

  // SystemChrome.setPreferredOrientations( // If you need this
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(const LearnHausaApp());
}

class LearnHausaApp extends StatelessWidget {
  const LearnHausaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
      ],
      child: MaterialApp(
        title: 'Learn Hausa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WelcomeScreen(), // Your initial screen
        // Define onGenerateRoute to handle named navigation
        onGenerateRoute: (RouteSettings settings) {
          print("Navigate to: ${settings.name}"); // For debugging
          switch (settings.name) {
            case '/SignInScreen':
              return MaterialPageRoute(
                builder: (_) => const SignInScreen(),
                settings: settings, // Good practice to pass settings
              );
          // Add other routes here as needed
          case '/SignUpScreen':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
            default:
            // Optionally handle unknown routes, e.g., show a NotFoundScreen
            // return MaterialPageRoute(builder: (_) => Scaffold(body: Center(child: Text('Route not found: ${settings.name}'))));
              print('Unknown route: ${settings.name}');
              return null; // Or throw an exception
          }
        },
      ),
    );
  }
}

