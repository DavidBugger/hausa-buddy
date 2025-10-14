import 'package:flutter/material.dart';
import 'package:learn_hausa/screens/auth/sign_up_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/vocabulary/vocabulary_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/bookmarks/bookmark_screens.dart';
import 'providers/auth_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/lesson_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/bookmark_provider.dart';
import 'providers/chat_provider.dart';
import 'services/database_service.dart';

// Firebase and Crashlytics imports (Add these back when you're ready)
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:flutter/foundation.dart' show kDebugMode, PlatformDispatcher;
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize Flutter binding

  // Initialize Hive database
  await DatabaseService().initialize();

  // Check if user is new or returning
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('is_first_time') ?? true;

  // Mark as not first time for next launches
  if (isFirstTime) {
    await prefs.setBool('is_first_time', false);
  }

  // SystemChrome.setPreferredOrientations( // If you need this
  //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(LearnHausaApp(isFirstTime: isFirstTime));
}

class LearnHausaApp extends StatelessWidget {
  final bool isFirstTime;

  const LearnHausaApp({Key? key, required this.isFirstTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Learn Hausa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: isFirstTime ? const WelcomeScreen() : const SignInScreen(),
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
          case '/ForgotPasswordScreen':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
          case '/OTPScreen':
            return MaterialPageRoute(builder: (_) => const OTPScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen()); // Navigate to proper home screen after login
          case '/chat':
            return MaterialPageRoute(builder: (_) => const ChatScreen());
          case '/vocabulary':
            return MaterialPageRoute(builder: (_) => const VocabularyScreen());
          case '/quiz':
            return MaterialPageRoute(builder: (_) => const QuizScreen());
          case '/bookmarks':
            return MaterialPageRoute(builder: (_) => const BookmarksScreen());
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
