// ignore_for_file: avoid_print

import 'dart:io';
import 'package:clica/enums/enums.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/providers/chat_provider.dart';
import 'package:clica/providers/group_provider.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/message_reply_preview.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound_record/flutter_sound_record.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class BottomChatField extends StatefulWidget {
  const BottomChatField({
    super.key,
    required this.contactUID,
    required this.contactName,
    required this.contactImage,
    required this.groupId,
  });

  final String contactUID, contactName, contactImage, groupId;

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  late final FlutterSoundRecord _soundRecord;
  late final TextEditingController _textEditingController;
  late final FocusNode _focusNode;

  String filePath = '';
  File? finalFileImage;
  bool isRecording = false;
  bool isShowSendButton = false;
  bool isSendingAudio = false;
  bool isShowEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _soundRecord = FlutterSoundRecord();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _soundRecord.dispose();
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<void> startRecording() async {
    if (await checkMicrophonePermission()) {
      final tempDir = await getTemporaryDirectory();
      filePath = '${tempDir.path}/flutter_sound.aac';
      await _soundRecord.start(path: filePath);
      setState(() => isRecording = true);
    }
  }

  Future<void> stopRecording() async {
    await _soundRecord.stop();
    setState(() {
      isRecording = false;
      isSendingAudio = true;
    });
    sendFileMessage(messageType: MessageEnum.audio);
  }

  Future<void> selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFail: (msg) => showSnackBar(context, msg),
    );
    await cropImage(finalFileImage?.path);
    Navigator.pop(context);
  }

  Future<void> selectVideo() async {
    final fileVideo = await pickVideo(
      onFail: (msg) => showSnackBar(context, msg),
    );
    Navigator.pop(context);
    if (fileVideo != null) {
      filePath = fileVideo.path;
      sendFileMessage(messageType: MessageEnum.video);
    }
  }

  Future<void> cropImage(String? croppedFilePath) async {
    if (croppedFilePath != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: croppedFilePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      if (croppedFile != null) {
        filePath = croppedFile.path;
        sendFileMessage(messageType: MessageEnum.image);
      }
    }
  }

  void sendFileMessage({required MessageEnum messageType}) {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    context.read<ChatProvider>().sendFileMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      file: File(filePath),
      messageType: messageType,
      groupId: widget.groupId,
      onSucess: () {
        _textEditingController.clear();
        // _focusNode.unfocus(); // Keep focus after sending
        setState(() => isSendingAudio = false);
      },
      onError: (error) {
        setState(() => isSendingAudio = false);
        showSnackBar(context, error);
      },
    );
  }

  void sendTextMessage() {
    final currentUser = context.read<AuthenticationProvider>().userModel!;
    context.read<ChatProvider>().sendTextMessage(
      sender: currentUser,
      contactUID: widget.contactUID,
      contactName: widget.contactName,
      contactImage: widget.contactImage,
      message: _textEditingController.text,
      messageType: MessageEnum.text,
      groupId: widget.groupId,
      onSucess: () {
        _textEditingController.clear();
        // _focusNode.unfocus(); // Keep focus after sending
      },
      onError: (error) => showSnackBar(context, error),
    );
  }

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiPicker) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => isShowEmojiPicker = !isShowEmojiPicker);
  }

  Widget buildBottomChatField() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        final isReplying = chatProvider.messageReplyModel != null;
        return Column(
          children: [
            if (isReplying)
              MessageReplyPreview(replyMessageModel: chatProvider.messageReplyModel!),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(isShowEmojiPicker ? Icons.keyboard_alt : Icons.emoji_emotions_outlined),
                    onPressed: toggleEmojiKeyboardContainer,
                  ),
                  IconButton(
                    icon: const Icon(Icons.attachment),
                    onPressed: isSendingAudio
                        ? null
                        : () => showModalBottomSheet(
                              context: context,
                              builder: (_) => Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: const Text('Camera'),
                                    onTap: () => selectImage(true),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.image),
                                    title: const Text('Gallery'),
                                    onTap: () => selectImage(false),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.video_library),
                                    title: const Text('Video'),
                                    onTap: selectVideo,
                                  ),
                                ],
                              ),
                            ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: TextFormField(
                      controller: _textEditingController,
                      focusNode: _focusNode,
                      decoration: const InputDecoration.collapsed(
                        hintText: 'Type a message',
                      ),
                      onChanged: (val) =>
                          setState(() => isShowSendButton = val.trim().isNotEmpty),
                      onTap: () => setState(() => isShowEmojiPicker = false),
                    ),
                  ),
                  chatProvider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        )
                      : GestureDetector(
                          onTap: isShowSendButton ? sendTextMessage : null,
                          onLongPress: isShowSendButton ? null : startRecording,
                          onLongPressUp: stopRecording,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              isShowSendButton ? Icons.arrow_upward : Icons.mic,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ],
              ),
            ),
            if (isShowEmojiPicker)
              SizedBox(
                height: 280,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    _textEditingController.text += emoji.emoji;
                    if (!isShowSendButton) {
                      setState(() => isShowSendButton = true);
                    }
                  },
                  onBackspacePressed: () {
                    final text = _textEditingController.text;
                    _textEditingController.text = text.characters.skipLast(1).toString();
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget buildLockedMessages() {
    final uid = context.read<AuthenticationProvider>().userModel!.uid;
    final groupProvider = context.read<GroupProvider>();
    final isAdmin = groupProvider.groupModel.adminsUIDs.contains(uid);
    final isMember = groupProvider.groupModel.membersUIDs.contains(uid);
    final isLocked = groupProvider.groupModel.lockMessages;

    if (isAdmin || (isMember && !isLocked)) {
      return buildBottomChatField();
    } else if (isMember && isLocked) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: Text(
            'Messages are locked, only admins can send messages',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: 60,
        child: Center(
          child: TextButton(
            onPressed: () async {
              await groupProvider.sendRequestToJoinGroup(
                groupId: groupProvider.groupModel.groupId,
                uid: uid,
                groupName: groupProvider.groupModel.groupName,
                groupImage: groupProvider.groupModel.groupImage,
              );
              showSnackBar(context, 'Request sent');
            },
            child: const Text(
              'You are not a member of this group,\nclick here to send request to join',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.groupId.isNotEmpty ? buildLockedMessages() : buildBottomChatField();
  }
}
