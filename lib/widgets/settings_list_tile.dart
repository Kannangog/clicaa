import 'dart:io';

import 'package:flutter/material.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconContainerColor,
    required this.onTap,
    this.textColor,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconContainerColor;
  final Function() onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        decoration: BoxDecoration(
          color: iconContainerColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        title,
        style: textColor != null ? TextStyle(color: textColor) : null,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textColor != null ? TextStyle(color: textColor) : null,
            )
          : null,
      trailing: Icon(
        Platform.isAndroid ? Icons.arrow_forward : Icons.arrow_back_ios_new,
        color: textColor,
      ),
      onTap: onTap,
    );
  }
}