import 'package:clica/constants.dart';
import 'package:clica/widgets/botton_chat_field.dart';
import 'package:clica/widgets/chat_app_bar.dart';
import 'package:clica/widgets/chat_list.dart';
import 'package:clica/widgets/group_chat_app_bar.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: isGroupChat
            ? GroupChatAppBar(groupId: groupId ?? '')
            : ChatAppBar(contactUID: contactUID ?? ''),
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