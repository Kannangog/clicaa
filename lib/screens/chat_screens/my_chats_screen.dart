import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/streams/chats_stream.dart';
import 'package:clica/streams/search_stream.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyChatsScreen extends StatelessWidget {
  const MyChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CupertinoSearchTextField(
                  placeholder: 'Search',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  onChanged: chatProvider.setSearchQuery,
                ),
              ),
              Expanded(
                child: chatProvider.searchQuery.isEmpty
                    ? ChatsStream(uid: uid)
                    : SearchStream(uid: uid),
              ),
            ],
          );
        },
      ),
    );
  }
}
