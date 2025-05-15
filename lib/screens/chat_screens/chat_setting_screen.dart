// ignore_for_file: use_build_context_synchronously

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatSettingScreen extends StatefulWidget {
  const ChatSettingScreen({super.key});

  @override
  State<ChatSettingScreen> createState() => _ChatSettingScreenState();
}

class _ChatSettingScreenState extends State<ChatSettingScreen> {
    bool _isDarkMode = false;

  // get the saved theme mode
  Future<void> getThemeMode() async { // Made this a Future
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    setState(() {
      _isDarkMode = savedThemeMode == AdaptiveThemeMode.dark; // Simplified logic
    });
  }

  @override
  void initState() {
    super.initState(); // Moved super.initState() first
    getThemeMode();
  }
  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthenticationProvider>().userModel;

    // get the uid from arguments
    final uid = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(onPressed: (){
          Navigator.pop(context);

        },),
        centerTitle: true,
        title: const Text('Settings'),
        actions: [
          currentUser!.uid == uid
              ? 
          // logout button
          IconButton(
            onPressed: () async {
             // create a dialog to confirm logout
              showDialog(
                context: context, 
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await context
                          .read<AuthenticationProvider>()
                          .logout()
                          .whenComplete((){
                            Navigator.pop(context);
                 Navigator.pushNamedAndRemoveUntil(
                context,
                Constants.loginScreen,
                (route) => false);
             }
             );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ));
            },
            icon: const Icon(Icons.logout),
          ): const SizedBox(),
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20), // Added margin for better spacing
          child: SwitchListTile(
            title: const Text('Change Theme'),
            secondary: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.white : Colors.black,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: _isDarkMode ? Colors.black : Colors.white,
              ),
            ),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              if (value) {
                AdaptiveTheme.of(context).setDark();
              } else {
                AdaptiveTheme.of(context).setLight();
              }
            },
          ),
        ),
      ),
    );
  }
}