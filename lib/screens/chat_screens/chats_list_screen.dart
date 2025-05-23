import 'package:clica/models/last_message_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsListsScreen extends StatefulWidget {
  const ChatsListsScreen({super.key});

  @override
  State<ChatsListsScreen> createState() => _ChatsListsScreenState();
}

class _ChatsListsScreenState extends State<ChatsListsScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
        
            // cupertinoSearchbar
            CupertinoSearchTextField(
              placeholder: 'Search',
              style: const TextStyle(
                color: Colors.white,
              ),
              onChanged: (value) {
                // search for friends
              },
            ),
        
            Expanded(
            child: StreamBuilder<List<LastMessageModel>>(
              stream: context.read<ChatProvider>().getChatsListStream(uid), 
              builder: (context,snapshot){
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Something went wrong'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  final chatsList = snapshot.data!;
                  return ListView.builder(
                    itemCount: chatsList.length,
                    itemBuilder: (context, index) {
                      final chat = chatsList[index];
                      final dateTime = 
                      formatDate(chat.timeSent,[hh, ':', nn, ' ', am],);
                      // check if we sent the last message
                      final isMe = chat.senderUID == uid;
                      // dis the last message correctly
                      final lastMessage = isMe
                       ? 'You: ${chat.message}' 
                       : chat.message;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(chat.contactImage),
                        ),
                        title: Text( chat.contactName,),
                        subtitle: Text(
                          lastMessage, 
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                           ),
                        trailing: Text(dateTime),
                        onTap: () {
                          Navigator.pushNamed(
                            context, 
                            Constants.chatScreen,
                            arguments: {
                              Constants.contactUID: chat.contactUID,
                              Constants.contactName: chat.contactName,
                              Constants.contactImage: chat.contactImage,
                              Constants.groupID:'',
                            },
                            );
                        },
                      );
                    },
                  );
                }
                // Add a default return widget
                return const Center(
                  child: Text('NO Chats Found'),
                  );
              },
              ),
            ),
          ],
        ),
      ),
    );
  }
}