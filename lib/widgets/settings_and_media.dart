import 'package:clica/providers/group_provider.dart';
import 'package:clica/screens/chat_screens/group_setting_screen.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/settings_list_tile.dart';
import 'package:flutter/material.dart';

class SettingsAndMedia extends StatelessWidget {
  const SettingsAndMedia({
    super.key,
    required this.groupProvider,
    required this.isAdmin,
    required this.onDeletePressed,
  });

  final GroupProvider groupProvider;
  final bool isAdmin;
  final VoidCallback? onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            SettingsListTile(
              title: 'Media',
              icon: Icons.image,
              iconContainerColor: Colors.deepPurple,
              onTap: () {
                // navigate to media screen
              },
            ),
            const Divider(
              thickness: 0.5,
              color: Colors.grey,
            ),
            SettingsListTile(
              title: 'Group Settings',
              icon: Icons.settings,
              iconContainerColor: Colors.deepPurple,
              onTap: () {
                if (!isAdmin) {
                  showSnackBar(context, 'Only admin can change group settings');
                } else {
                  groupProvider.updateGroupAdminsList().whenComplete(() {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const GroupSettingsScreen(),
                      ),
                    );
                  });
                }
              },
            ),
            if (isAdmin && onDeletePressed != null) ...[
              const Divider(
                thickness: 0.5,
                color: Colors.grey,
              ),
              SettingsListTile(
                title: 'Delete Group',
                icon: Icons.delete,
                iconContainerColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  if (onDeletePressed != null) {
                    onDeletePressed!();
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}