import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:clica/authentication/landing_screen.dart';
import 'package:clica/authentication/login_screen.dart';
import 'package:clica/authentication/otp_screen.dart';
import 'package:clica/authentication/user_information_screen.dart';
import 'package:clica/firebase_options.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/screens/chat_screens/chat_home_screen.dart';
import 'package:clica/screens/chat_screens/chat_screen.dart';
import 'package:clica/screens/chat_screens/friends_requests_screen.dart';
import 'package:clica/screens/chat_screens/friends_screen.dart';
import 'package:clica/screens/chat_screens/group_information_screen.dart';
import 'package:clica/screens/chat_screens/group_setting_screen.dart';
import 'package:clica/screens/chat_screens/profile_screen.dart';
import 'package:clica/constants.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MyApp(savedThemeMode: savedThemeMode),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.savedThemeMode});

  final AdaptiveThemeMode? savedThemeMode;

  // This widget is the root of your application.
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
      initial: savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Chat Pro',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: Constants.landingScreen,
        routes: {
          Constants.landingScreen: (context) => const LandingScreen(),
          Constants.loginScreen: (context) => const LoginScreen(),
          Constants.otpScreen: (context) => const OTPScreen(),
          Constants.userInformationScreen: (context) =>
              const UserInformationScreen(enableUpdatingInformation: false,),
          Constants.homeScreen: (context) => const HomeScreen(),
          Constants.profileScreen: (context) => const ProfileScreen(),
          Constants.friendsScreen: (context) => const FriendsScreen(),
          Constants.friendRequestsScreen: (context) =>
              const FriendRequestScreen(),
          Constants.chatScreen: (context) => const ChatScreen(),
          Constants.groupSettingsScreen: (context) =>
              const GroupSettingsScreen(),
          Constants.groupInformationScreen: (context) =>
              const GroupInformationScreen(),
        },
      ),
    );
  }
}