import 'package:clica/models/group_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/constants.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/widgets/chat_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrivateGroupScreen extends StatefulWidget {
  const PrivateGroupScreen({super.key, required String searchQuery});

  @override
  State<PrivateGroupScreen> createState() => _PrivateGroupScreenState();
}

class _PrivateGroupScreenState extends State<PrivateGroupScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              placeholder: 'Search private groups',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<GroupModel>>(
              stream: context.read<GroupProvider>().getPrivateGroupsStream(userId: uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No private groups'));
                }

                final filteredGroups = snapshot.data!.where((group) {
                  return group.groupName.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredGroups.isEmpty) {
                  return Center(
                    child: Text(
                      'No groups match "$_searchQuery"',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    return ChatWidget(
                      group: group,
                      isGroup: true,
                      onTap: () {
                        context.read<GroupProvider>()
                          .setGroupModel(groupModel: group)
                          .whenComplete(() {
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: group.groupId,
                                Constants.contactName: group.groupName,
                                Constants.contactImage: group.groupImage,
                                Constants.groupId: group.groupId,
                              },
                            );
                          });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}