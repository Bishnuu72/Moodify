import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'constants/colors.dart';
import 'services/auth_service.dart';
import 'services/navigation_service.dart';
import 'providers/user_profile_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization failed: $e');
    // Handle error or run without Firebase for UI testing if needed
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider<AuthService, UserProfileProvider>(
          create: (context) => UserProfileProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (context, authService, previous) => previous ?? UserProfileProvider(authService),
        ),
      ],
      child: MaterialApp(
        title: 'Moodify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            displayMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            bodyLarge: TextStyle(color: AppColors.textPrimary),
            bodyMedium: TextStyle(color: AppColors.textSecondary),
          ),
          useMaterial3: true,
        ),
        navigatorKey: NavigationService.navigatorKey,
        home: const LoginScreen(),
      ),
    );
  }
}
