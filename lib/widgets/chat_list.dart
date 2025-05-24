import 'package:clica/models/message_model.dart';
import 'package:clica/models/message_reply_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/contact_message_widget.dart';
import 'package:clica/widgets/my_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key, required this.contactUID, required this.groupID});
  final String contactUID;
  final String groupID;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {
     // get the current user id
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    return StreamBuilder<List<MessageModel>>(
                stream: context.read<ChatProvider>().getMessagesStream(
                  userId: uid,
                  contactUID: widget.contactUID,
                  isGroup: widget.groupID, 
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
                  if(snapshot.data!.isEmpty){
                    return  Center(
                      child: Text('No messages yet', textAlign:TextAlign.center,style: GoogleFonts.openSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2
                      ),),
                    );
                  }
                  if (snapshot.hasData) {
                    final messagesList = snapshot.data!;
                    return GroupedListView<dynamic, DateTime>(
                      reverse: true,
                      elements: messagesList,
                      groupBy: (element) {
                        return DateTime(
                          element.timestamp!.year,
                          element.timestamp!.month,
                          element.timestamp!.day,
                        );
                      },
                      groupHeaderBuilder: (dynamic groupedByValue) =>
                          SizedBox( height: 40,
                            child: buildDateTime(groupedByValue)),
                      itemBuilder: (context, dynamic element) {
                        final isMe = element.senderId == uid;
                        return isMe ? Padding(
                          padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                          child: MyMessageWidget(
                            message: element,
                            onRightSwipe: (){
                              // set the message reply to true
                              final messageReply = MessageReplyModel(
                                message: element.message,
                                 senderUID: element.senderUID, 
                                 senderName: element.senderName, 
                                 senderImage: element.senderImage, 
                                 messageType: element.messageType, 
                                 isMe: isMe,
                                 );
                                 context
                                 .read<ChatProvider>()
                                 .setMessageReplyModel(messageReply);
                            }
                            ),
                        )
                         : Padding(
                          padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
                          child: ContactMessageWidget(
                            message: element,
                            onRightSwipe: (){
                              final messageReply = MessageReplyModel(
                                message: element.message,
                                 senderUID: element.senderUID, 
                                 senderName: element.senderName, 
                                 senderImage: element.senderImage, 
                                 messageType: element.messageType, 
                                 isMe: isMe,
                                 );
                                 context
                                 .read<ChatProvider>()
                                 .setMessageReplyModel(messageReply);
                            }
                            ),
                        );
                      },
                      groupComparator: (value1, value2) =>
                             value2.compareTo(value1), // optional
                      itemComparator: (item1, item2) {
                        var firstItem = item1.timeSent;

                        var secondItem = item2.timeSent;

                        return secondItem.compareTo(firstItem);

                      }, // optional
                       useStickyGroupSeparators: true, // optional
                      floatingHeader: true, // optional
                      order: GroupedListOrder.ASC, // optional
                     );
                  } 
                    return const SizedBox.shrink();
                  
                }
              );
  }
}