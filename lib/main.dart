import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:clica/authentication/landing_screen.dart';
import 'package:clica/authentication/login_screen.dart';
import 'package:clica/authentication/otp_screen.dart';
import 'package:clica/authentication/user_information_screen.dart';
import 'package:clica/firebase_options.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/screens/chat_screens/chat_home_screen.dart';
import 'package:clica/screens/chat_screens/chat_setting_screen.dart';
import 'package:clica/screens/chat_screens/profile_screen.dart';
import 'package:clica/utilities/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(
    MultiProvider(providers: [
      ChangeNotifierProvider(
        create: (_) => AuthenticationProvider(),),
    ],child: 
    MyApp(savedThemeMode: savedThemeMode),),);
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.deepPurple,
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.light, // Use saved theme if available
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Clica',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OtpScreen(),
          Constants.userInformationScreen: (context) => const UserInformationScreen(),
          Constants.homeScreen: (context) => const ChatHomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.settingsScreen: (context) => const ChatSettingScreen(),
        },
      ),
    );
  }
}