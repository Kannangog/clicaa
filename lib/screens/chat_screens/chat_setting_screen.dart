import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
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