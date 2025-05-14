import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    IconData icon;

    if (kIsWeb) {
      icon = Icons.arrow_back; // Default for web
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      icon = Icons.arrow_back_ios_new;
    } else {
      icon = Icons.arrow_back;
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }
}
