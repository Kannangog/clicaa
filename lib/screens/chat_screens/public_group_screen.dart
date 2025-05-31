import 'package:clica/constants.dart';
import 'package:clica/models/group_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/chat_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PublicGroupScreen extends StatefulWidget {
  const PublicGroupScreen({super.key, required String searchQuery});

  @override
  State<PublicGroupScreen> createState() => _PublicGroupScreenState();
}

class _PublicGroupScreenState extends State<PublicGroupScreen> {
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
              placeholder: 'Search public groups',
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          // stream builder for public groups
          StreamBuilder<List<GroupModel>>(
            stream: context.read<GroupProvider>().getPublicGroupsStream(userId: uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Something went wrong'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No Public groups'),
                );
              }

              // Filter groups based on search query
              final filteredGroups = snapshot.data!.where((group) {
                return group.groupName.toLowerCase().contains(_searchQuery) ||
                    (group.groupDescription.toLowerCase().contains(_searchQuery));
              }).toList();

              if (filteredGroups.isEmpty) {
                return const Center(
                  child: Text('No groups match your search'),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final groupModel = filteredGroups[index];
                    return ChatWidget(
                      group: groupModel,
                      isGroup: true,
                      onTap: () {
                        // check if user is already a member of the group
                        if (groupModel.membersUIDs.contains(uid)) {
                          context
                              .read<GroupProvider>()
                              .setGroupModel(groupModel: groupModel)
                              .whenComplete(() {
                            Navigator.pushNamed(
                              context,
                              Constants.chatScreen,
                              arguments: {
                                Constants.contactUID: groupModel.groupId,
                                Constants.contactName: groupModel.groupName,
                                Constants.contactImage: groupModel.groupImage,
                                Constants.groupId: groupModel.groupId,
                              },
                            );
                          });
                          return;
                        }

                        // check if request to join settings is enabled
                        if (groupModel.requestToJoing) {
                          // check if user has already requested to join the group
                          if (groupModel.awaitingApprovalUIDs.contains(uid)) {
                            showSnackBar(context, 'Request already sent');
                            return;
                          }

                          // show animation to join group to request to join
                          showMyAnimatedDialog(
                            context: context,
                            title: 'Request to join',
                            content:
                                'You need to request to join this group, before you can view the group content',
                            textAction: 'Request to join',
                            onActionTap: (value) async {
                              // send request to join group
                              if (value) {
                                await context
                                    .read<GroupProvider>()
                                    .sendRequestToJoinGroup(
                                      groupId: groupModel.groupId,
                                      uid: uid,
                                      groupName: groupModel.groupName,
                                      groupImage: groupModel.groupImage,
                                    )
                                    .whenComplete(() {
                                  showSnackBar(context, 'Request sent');
                                });
                              }
                            },
                          );
                          return;
                        }

                        context
                            .read<GroupProvider>()
                            .setGroupModel(groupModel: groupModel)
                            .whenComplete(() {
                          Navigator.pushNamed(
                            context,
                            Constants.chatScreen,
                            arguments: {
                              Constants.contactUID: groupModel.groupId,
                              Constants.contactName: groupModel.groupName,
                              Constants.contactImage: groupModel.groupImage,
                              Constants.groupId: groupModel.groupId,
                            },
                          );
                        });
                      },
                    );
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }
}