import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/add_members.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:clica/widgets/exit_group_card.dart';
import 'package:clica/widgets/group_details_card.dart';
import 'package:clica/widgets/group_members_card.dart';
import 'package:clica/widgets/settings_and_media.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class GroupInformationScreen extends StatefulWidget {
  const GroupInformationScreen({super.key});

  @override
  State<GroupInformationScreen> createState() => _GroupInformationScreenState();
}

class _GroupInformationScreenState extends State<GroupInformationScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    bool isMember =
        context.read<GroupProvider>().groupModel.membersUIDs.contains(uid);
    return Consumer<GroupProvider>(
      builder: (context, groupProvider, child) {
        bool isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);

        return Scaffold(
          appBar: AppBar(
            leading: AppBarBackButton(onPressed: () {
              Navigator.pop(context);
            }),
            centerTitle: true,
            title: const Text('Group Information'),
            actions: [
              if (isAdmin)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditGroupDialog(context, groupProvider),
                ),
            ],
          ),
          body: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InfoDetailsCard(
                  groupProvider: groupProvider,
                  isAdmin: isAdmin,
                  onEditPressed: isAdmin ? () => _showEditGroupDialog(context, groupProvider) : () {},
                ),
                const SizedBox(height: 10),
                SettingsAndMedia(
                  groupProvider: groupProvider,
                  isAdmin: isAdmin,
                  onDeletePressed: isAdmin ? () => _showDeleteGroupDialog(context, groupProvider) : null,
                ),
                const SizedBox(height: 20),
                AddMembers(
                  groupProvider: groupProvider,
                  isAdmin: isAdmin,
                  onPressed: () {
                    showAddMembersBottomSheet(
                      context: context,
                      groupMembersUIDs: groupProvider.groupModel.membersUIDs,
                    );
                  },
                ),
                const SizedBox(height: 20),
                isMember
                    ? Column(
                        children: [
                          GoupMembersCard(
                            isAdmin: isAdmin,
                            groupProvider: groupProvider,
                          ),
                          const SizedBox(height: 10),
                          ExitGroupCard(
                            uid: uid,
                          )
                        ],
                      )
                    : const SizedBox(),
              ],
            )),
          ),
        );
      },
    );
  }

  void _showEditGroupDialog(BuildContext context, GroupProvider groupProvider) {
    final TextEditingController nameController = TextEditingController(
      text: groupProvider.groupModel.groupName,
    );
    final TextEditingController descriptionController = TextEditingController(
      text: groupProvider.groupModel.groupDescription,
    );
    Uint8List? newImage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Edit Group Info'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final file = await pickImage(
                          context,
                          fromCamera: false,
                          onFail: (String error) {},
                        );
                        Uint8List? image;
                        if (file != null) {
                          image = await file.readAsBytes();
                        }
                        if (image != null) {
                          setState(() => newImage = image);
                        }
                      },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: newImage != null
                            ? MemoryImage(newImage!)
                            : (groupProvider.groupModel.groupImage.isNotEmpty
                                ? NetworkImage(
                                    groupProvider.groupModel.groupImage)
                                : const AssetImage('assets/default_group.png'))
                                as ImageProvider,
                        child: newImage == null &&
                                groupProvider.groupModel.groupImage.isEmpty
                            ? const Icon(Icons.group, size: 40)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) {
                      showSnackBar(context, 'Group name cannot be empty');
                      return;
                    }

                    try {
                      await groupProvider.updateGroupInfo(
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        imageBytes: newImage,
                      );
                      if (mounted) {
                        Navigator.pop(context);
                        showSnackBar(context, 'Group updated successfully');
                      }
                    } catch (e) {
                      if (mounted) {
                        showSnackBar(context, 'Failed to update group: $e');
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteGroupDialog(BuildContext context, GroupProvider groupProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Group'),
          content: const Text('Are you sure you want to delete this group? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                try {
                  await groupProvider.deleteGroup();
                  if (mounted) {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                    showSnackBar(context, 'Group deleted successfully');
                  }
                } catch (e) {
                  if (mounted) {
                    showSnackBar(context, 'Failed to delete group: $e');
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}