import 'package:clica/models/message_model.dart';
import 'package:clica/models/message_reply_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/align_message_left_widget.dart';
import 'package:clica/widgets/align_message_right_widget.dart';
import 'package:clica/widgets/full_screen_image.dart';
import 'package:clica/widgets/message_widget.dart'; // ✅ Import your image viewer
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_reactions/flutter_chat_reactions.dart';
import 'package:flutter_chat_reactions/utilities/hero_dialog_route.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    super.key,
    required this.contactUID,
    required this.groupId,
  });

  final String contactUID;
  final String groupId;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void onContextMenyClicked({required String item, required MessageModel message}) {
    final currentUser = context.read<AuthenticationProvider>().userModel;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final groupProvider = context.read<GroupProvider>();

    switch (item) {
      case 'Reply':
        final messageReply = MessageReplyModel(
          message: message.message,
          senderUID: message.senderUID,
          senderName: message.senderName,
          senderImage: message.senderImage,
          messageType: message.messageType,
          isMe: true,
        );
        context.read<ChatProvider>().setMessageReplyModel(messageReply);
        break;

      case 'Copy':
        Clipboard.setData(ClipboardData(text: message.message));
        showSnackBar(context, 'Message copied to clipboard');
        break;

      case 'Delete':
        final isGroup = widget.groupId.isNotEmpty;
        final isSenderOrAdmin = isGroup
            ? groupProvider.isSenderOrAdmin(message: message, uid: currentUserId)
            : true;
        showDeletBottomSheet(
          message: message,
          currentUserId: currentUserId,
          isSenderOrAdmin: isSenderOrAdmin,
        );
        break;
    }
  }

  void showDeletBottomSheet({
    required MessageModel message,
    required String currentUserId,
    required bool isSenderOrAdmin,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) {
        return Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chatProvider.isLoading) const LinearProgressIndicator(),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete for me'),
                      onTap: chatProvider.isLoading
                          ? null
                          : () async {
                              await chatProvider
                                  .deleteMessage(
                                    currentUserId: currentUserId,
                                    contactUID: widget.contactUID,
                                    messageId: message.messageId,
                                    messageType: message.messageType.name,
                                    isGroupChat: widget.groupId.isNotEmpty,
                                    deleteForEveryone: false,
                                  )
                                  .whenComplete(() {
                                Navigator.pop(context);
                              });
                            },
                    ),
                    if (isSenderOrAdmin)
                      ListTile(
                        leading: const Icon(Icons.delete_forever),
                        title: const Text('Delete for everyone'),
                        onTap: chatProvider.isLoading
                            ? null
                            : () async {
                                await chatProvider
                                    .deleteMessage(
                                      currentUserId: currentUserId,
                                      contactUID: widget.contactUID,
                                      messageId: message.messageId,
                                      messageType: message.messageType.name,
                                      isGroupChat: widget.groupId.isNotEmpty,
                                      deleteForEveryone: true,
                                    )
                                    .whenComplete(() {
                                  Navigator.pop(context);
                                });
                              },
                      ),
                    ListTile(
                      leading: const Icon(Icons.cancel),
                      title: const Text('Cancel'),
                      onTap: chatProvider.isLoading ? null : () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void sendReactionToMessage({required String reaction, required String messageId}) {
    final senderUID = context.read<AuthenticationProvider>().userModel?.uid;
    if (senderUID == null) return;

    context.read<ChatProvider>().sendReactionToMessage(
          senderUID: senderUID,
          contactUID: widget.contactUID,
          messageId: messageId,
          reaction: reaction,
          groupId: widget.groupId.isNotEmpty,
        );
  }

  void showEmojiContainer({required String messageId}) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 300,
        child: EmojiPicker(
          onEmojiSelected: (category, emoji) {
            Navigator.pop(context);
            sendReactionToMessage(reaction: emoji.emoji, messageId: messageId);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel?.uid;
    if (uid == null) {
      return const Center(child: Text("User not logged in"));
    }

    return StreamBuilder<List<MessageModel>>(
      stream: context.read<ChatProvider>().getMessagesStream(
            userId: uid,
            contactUID: widget.contactUID,
            isGroup: widget.groupId,
          ),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'Start a conversation',
              textAlign: TextAlign.center,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        });

        final messagesList = snapshot.data!;
        return Expanded(
          child: GroupedListView<MessageModel, DateTime>(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            reverse: true,
            controller: _scrollController,
            elements: messagesList,
            groupBy: (element) {
              final timeSent = element.timeSent;
              return DateTime(timeSent.year, timeSent.month, timeSent.day);
            },
            groupSeparatorBuilder: (DateTime groupedByValue) =>
                SizedBox(height: 40, child: buildDateTime(groupedByValue)),
            itemBuilder: (context, MessageModel message) {
            if (message.deletedBy.contains(uid)) return const SizedBox.shrink();

            final isMe = message.senderUID == uid;

            if (widget.groupId.isNotEmpty) {
              context.read<ChatProvider>().setMessageStatus(
                    currentUserId: uid,
                    contactUID: widget.contactUID,
                    messageId: message.messageId,
                    isSeenByList: message.isSeenBy,
                    isGroupChat: true,
                  );
            } else if (!message.isSeen && message.senderUID != uid) {
              context.read<ChatProvider>().setMessageStatus(
                    currentUserId: uid,
                    contactUID: widget.contactUID,
                    messageId: message.messageId,
                    isSeenByList: message.isSeenBy,
                    isGroupChat: false,
                  );
            }

            return GestureDetector(
              onLongPress: () {
                Navigator.of(context).push(HeroDialogRoute(
                  builder: (context) => ReactionsDialogWidget(
                    id: message.messageId,
                    messageWidget: isMe
                        ? AlignMessageRightWidget(
                            message: message,
                            viewOnly: true,
                            isGroupChat: widget.groupId.isNotEmpty,
                          )
                        : AlignMessageLeftWidget(
                            message: message,
                            viewOnly: true,
                            isGroupChat: widget.groupId.isNotEmpty,
                          ),
                    onReactionTap: (reaction) {
                      if (reaction == '➕') {
                        showEmojiContainer(messageId: message.messageId);
                      } else {
                        sendReactionToMessage(reaction: reaction, messageId: message.messageId);
                      }
                    },
                    onContextMenuTap: (item) {
                      onContextMenyClicked(item: item.label, message: message);
                    },
                    widgetAlignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  ),
                ));
              },
              child: Hero(
                tag: message.messageId,
                child: MessageWidget(
                  message: message,
                  onRightSwipe: () {
                    final reply = MessageReplyModel(
                      message: message.message,
                      senderUID: message.senderUID,
                      senderName: message.senderName,
                      senderImage: message.senderImage,
                      messageType: message.messageType,
                      isMe: isMe,
                    );
                    context.read<ChatProvider>().setMessageReplyModel(reply);
                  },
                  isMe: isMe,
                  isGroupChat: widget.groupId.isNotEmpty,
                  onTap: () {
                    if (message.messageType.name == "image") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imageUrl: message.message,
                            heroTag: message.messageId,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
          itemComparator: (item1, item2) {
            final a = item1.timeSent;
            final b = item2.timeSent;
            return b.compareTo(a);
          },
         ) );
      },
    );
  }
}