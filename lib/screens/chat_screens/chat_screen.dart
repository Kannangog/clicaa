import 'package:clica/models/message_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:clica/widgets/botton_chat_field.dart';
import 'package:clica/widgets/chat_app_bar.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    // get the current user id
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    // get  arguments passed from the previous screen
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // get the contactUiD from the arguments
    final contactUID = arguments[Constants.contactUID];
    // get the contactName from the arguments
    final contactName = arguments[Constants.contactName];
    // get the contactImage from the arguments
    final contactImage = arguments[Constants.contactImage];
    // get the groupID from the arguments
    final groupID = arguments[Constants.groupID];

    // check if the groupID is empty - then its a chat with a friend else its agroup chat
    final isGroupChat = groupID.isNotEmpty ? true : false;


    return Scaffold(
      appBar: AppBar(
        title: ChatAppBar(contactUID: contactUID),),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(child:StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessagesStream(
                  userId: uid,
                  contactUID: contactUID,
                  isGroup: groupID,
                ),
                builder: (context , snapshot){
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
                    final messagesList = snapshot.data!;
                    return ListView.builder(
                      itemCount: messagesList.length,
                      itemBuilder: (context, index) {
                        final message = messagesList[index];
                        final dateTime = formatDate(
                          message.timeSent,
                          [hh, ':', nn, ' ', am],
                        );
                        // check if we sent the last message
                        final isMe = message.senderUID == uid;
                        return Card(
                          color:  isMe
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).cardColor,
                          child: ListTile(
                            title: Text(
                              message.message,
                              style: TextStyle(
                                color: isMe
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context).cardColor,
                              ),
                            ),
                            subtitle: Text(
                              dateTime,
                              style: TextStyle(
                                color: isMe
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).cardColor,
                              ),
                            ),
                        )
                        );
                      },
                    );
                  } 
                    return const SizedBox.shrink();
                  
                }
              )
              ),
              BottonChatField(
                contactUID: contactUID,
                constactName: contactName,
                contactImage: contactImage,
                groupId: groupID,
              ),
            ],
          ),
        ),
      
    );
  }
}