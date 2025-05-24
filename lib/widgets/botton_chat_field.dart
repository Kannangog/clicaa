import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/message_reply_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BottonChatField extends StatefulWidget {
  const BottonChatField(
    {super.key ,
    required this.contactUID,
     required this.constactName,
      required this.contactImage,
       required this.groupId});

  final String contactUID;
  final String constactName;
  final String contactImage;
  final String groupId;

  @override
  State<BottonChatField> createState() => _BottonChatFieldState();
}

class _BottonChatFieldState extends State<BottonChatField> {
  late TextEditingController _textEditingController;
  late FocusNode _focusNode;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
    super.initState();
  }
  @override
  void dispose() {
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  // send text message to firebasen 
  void sendTextMessage(){
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    final chatProvider = context.read<ChatProvider>();

    chatProvider.sendTextMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.constactName,
      contactImage: widget.contactImage,
      message: _textEditingController.text,
      messageType: MessageEnum.text,
      groupId: widget.groupId,
      onSuccess: () {
        _textEditingController.clear();
        _focusNode.unfocus();
      },
      onError: (error) {
        showSnackBar(context, error);
      },
       
    );
      

  }
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final messageReply = chatProvider.messageReplyModel;
        final isMessageReply = messageReply != null;
        return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).cardColor,
                  border: Border.all(
        color: Theme.of(context).primaryColor,
                  ),
                ),
                child: Column(
                  children: [
        isMessageReply
            ?const MessageReplyPreview()
            : const SizedBox.shrink(),
        Row(
          children: [
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context, 
                  builder: (context) {
                    return Container(
                      height: 200,
                      child: const Center(
                        child: Text('Attachment options'),
                      ),
                    );
                  },
                );
              },
              icon: const Icon(Icons.attachment),
            ),
            Expanded(
              child: TextFormField(
                controller: _textEditingController,
                focusNode: _focusNode,
                decoration: const InputDecoration.collapsed(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30)
                      ),
                    borderSide: BorderSide.none,
                  ),
                  hintText: 'Type a message',
                ),
              ),
            ),
            GestureDetector(
              onTap: sendTextMessage,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).primaryColor,
                ),
                margin: const EdgeInsets.all(5),
                child: const Padding(
                  padding:  EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
                  ],
                ),
              );
      },
    );
  }
}