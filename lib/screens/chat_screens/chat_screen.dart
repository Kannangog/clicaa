import 'package:clica/constants.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/widgets/botton_chat_field.dart';
import 'package:clica/widgets/chat_app_bar.dart';
import 'package:clica/widgets/chat_list.dart';
import 'package:clica/widgets/group_chat_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Map? arguments;
  String? contactUID;
  String? contactName;
  String? contactImage;
  String? groupId;
  bool isGroupChat = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      arguments = ModalRoute.of(context)!.settings.arguments as Map?;
      contactUID = arguments?[Constants.contactUID];
      contactName = arguments?[Constants.contactName];
      contactImage = arguments?[Constants.contactImage];
      groupId = arguments?[Constants.groupId];
      isGroupChat = (groupId != null && groupId!.isNotEmpty);
      _isInitialized = true;
    }
  }

  

  void showFullScreenImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          child: Center(
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: isGroupChat
        ? GroupChatAppBar(groupId: groupId ?? '')
        : ChatAppBar(contactUID: contactUID ?? ''),
        actions: [
          if (isGroupChat)
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // navigate to group information screen
            context
            .read<GroupProvider>()
            .updateGroupMembersList()
            .whenComplete(() {
          Navigator.pushNamed(context, Constants.groupInformationScreen);
            });
          },
          tooltip: 'Group info',
        ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: ChatList(
                contactUID: contactUID ?? '',
                groupId: groupId ?? '',
              ),
            ),
            BottomChatField(
              contactUID: contactUID ?? '',
              contactName: contactName ?? '',
              contactImage: contactImage ?? '',
              groupId: groupId ?? '',
            ),
          ],
        ),
      ),
    );
  }
}