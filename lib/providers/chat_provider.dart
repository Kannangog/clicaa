import 'dart:io';

import 'package:clica/constants.dart';
import 'package:clica/enums/enums.dart';
import 'package:clica/models/last_message_model.dart';
import 'package:clica/models/message_model.dart';
import 'package:clica/models/message_reply_model.dart';
import 'package:clica/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier {
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;
  String _searchQuery = '';

  // Getters
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  // Setters
  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Send text message
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupId,
    required VoidCallback onSucess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      final messageId = const Uuid().v4();
      final repliedMessage = _messageReplyModel?.message ?? '';
      final repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      final repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: message,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      if (groupId.isNotEmpty) {
        await _firestore
            .collection(Constants.groups)
            .doc(groupId)
            .collection(Constants.messages)
            .doc(messageId)
            .set(messageModel.toMap());

        await _firestore.collection(Constants.groups).doc(groupId).update({
          Constants.lastMessage: message,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        setLoading(false);
        onSucess();
        setMessageReplyModel(null);
      } else {
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );
        setMessageReplyModel(null);
      }
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  // Send file message
  Future<void> sendFileMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required File file,
    required MessageEnum messageType,
    required String groupId,
    required VoidCallback onSucess,
    required Function(String) onError,
  }) async {
    setLoading(true);
    try {
      final messageId = const Uuid().v4();
      final repliedMessage = _messageReplyModel?.message ?? '';
      final repliedTo = _messageReplyModel == null
          ? ''
          : _messageReplyModel!.isMe
              ? 'You'
              : _messageReplyModel!.senderName;
      final repliedMessageType =
          _messageReplyModel?.messageType ?? MessageEnum.text;

      final ref =
          '${Constants.chatFiles}/${messageType.name}/${sender.uid}/$contactUID/$messageId';
      final fileUrl = await storeFileToStorage(file: file, reference: ref);
      
      // Ensure fileUrl is not empty, and handle video type correctly
      if (fileUrl.isEmpty) {
        setLoading(false);
        onError('Failed to upload file.');
        return;
      }
      
      final messageModel = MessageModel(
        senderUID: sender.uid,
        senderName: sender.name,
        senderImage: sender.image,
        contactUID: contactUID,
        message: fileUrl,
        messageType: messageType,
        timeSent: DateTime.now(),
        messageId: messageId,
        isSeen: false,
        repliedMessage: repliedMessage,
        repliedTo: repliedTo,
        repliedMessageType: repliedMessageType,
        reactions: [],
        isSeenBy: [sender.uid],
        deletedBy: [],
      );

      if (groupId.isNotEmpty) {
        await _firestore
            .collection(Constants.groups)
            .doc(groupId)
            .collection(Constants.messages)
            .doc(messageId)
            .set(messageModel.toMap());

        await _firestore.collection(Constants.groups).doc(groupId).update({
          Constants.lastMessage: fileUrl,
          Constants.timeSent: DateTime.now().millisecondsSinceEpoch,
          Constants.senderUID: sender.uid,
          Constants.messageType: messageType.name,
        });

        setLoading(false);
        onSucess();
        setMessageReplyModel(null);
      } else {
        await handleContactMessage(
          messageModel: messageModel,
          contactUID: contactUID,
          contactName: contactName,
          contactImage: contactImage,
          onSucess: onSucess,
          onError: onError,
        );
        setMessageReplyModel(null);
      }
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  // Handle contact message
  Future<void> handleContactMessage({
    required MessageModel messageModel,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required VoidCallback onSucess,
    required Function(String) onError,
  }) async {
    try {
      final contactMessageModel = messageModel.copyWith(userId: messageModel.senderUID);

      final senderLastMessage = LastMessageModel(
        senderUID: messageModel.senderUID,
        contactUID: contactUID,
        contactName: contactName,
        contactImage: contactImage,
        message: messageModel.message,
        messageType: messageModel.messageType,
        timeSent: messageModel.timeSent,
        isSeen: false,
      );

      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      final batch = _firestore.batch();

      final senderMsgRef = _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId);

      final contactMsgRef = _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID)
          .collection(Constants.messages)
          .doc(messageModel.messageId);

      final senderLastMsgRef = _firestore
          .collection(Constants.users)
          .doc(messageModel.senderUID)
          .collection(Constants.chats)
          .doc(contactUID);

      final contactLastMsgRef = _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(messageModel.senderUID);

      batch.set(senderMsgRef, messageModel.toMap());
      batch.set(contactMsgRef, contactMessageModel.toMap());
      batch.set(senderLastMsgRef, senderLastMessage.toMap());
      batch.set(contactLastMsgRef, contactLastMessage.toMap());

      await batch.commit();

      setLoading(false);
      onSucess();
    } on FirebaseException catch (e) {
      setLoading(false);
      onError(e.message ?? e.toString());
    } catch (e) {
      setLoading(false);
      onError(e.toString());
    }
  }

  // Send reaction to message
  Future<void> sendReactionToMessage({
    required String senderUID,
    required String contactUID,
    required String messageId,
    required String reaction,
    required bool groupId,
  }) async {
    setLoading(true);
    final reactionToAdd = '$senderUID=$reaction';

    try {
      if (groupId) {
        final msgRef = _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId);

        final messageData = await msgRef.get();
        final message = MessageModel.fromMap(messageData.data()!);

        final uids = message.reactions.map((e) => e.split('=')[0]).toList();
        if (uids.contains(senderUID)) {
          final index = uids.indexOf(senderUID);
          message.reactions[index] = reactionToAdd;
        } else {
          message.reactions.add(reactionToAdd);
        }
        await msgRef.update({Constants.reactions: message.reactions});
      } else {
        final senderMsgRef = _firestore
            .collection(Constants.users)
            .doc(senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId);

        final contactMsgRef = _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(senderUID)
            .collection(Constants.messages)
            .doc(messageId);

        final messageData = await senderMsgRef.get();
        final message = MessageModel.fromMap(messageData.data()!);

        final uids = message.reactions.map((e) => e.split('=')[0]).toList();
        if (uids.contains(senderUID)) {
          final index = uids.indexOf(senderUID);
          message.reactions[index] = reactionToAdd;
        } else {
          message.reactions.add(reactionToAdd);
        }
        await senderMsgRef.update({Constants.reactions: message.reactions});
        await contactMsgRef.update({Constants.reactions: message.reactions});
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
    }
  }

  // Get chats list stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LastMessageModel.fromMap(doc.data()))
            .toList());
  }

  // Get messages stream
  Stream<List<MessageModel>> getMessagesStream({
    required String userId,
    required String contactUID,
    required String isGroup,
  }) {
    if (isGroup.isNotEmpty) {
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                try {
                  return MessageModel.fromMap(doc.data());
                } catch (e) {
                  // Optionally log error
                  return null;
                }
              })
              .whereType<MessageModel>()
              .toList());
    } else {
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) {
                try {
                  return MessageModel.fromMap(doc.data());
                } catch (e) {
                  // Optionally log error
                  return null;
                }
              })
              .whereType<MessageModel>()
              .toList());
    }
  }

  // Get unread messages stream
  Stream<int> getUnreadMessagesStream({
    required String userId,
    required String contactUID,
    required bool isGroup,
  }) {
    if (isGroup) {
      return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .snapshots()
          .map((event) => event.docs
              .where((doc) => !MessageModel.fromMap(doc.data()).isSeenBy.contains(userId))
              .length);
    } else {
      return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .where(Constants.isSeen, isEqualTo: false)
          .where(Constants.senderUID, isNotEqualTo: userId)
          .snapshots()
          .map((event) => event.docs.length);
    }
  }

  // Set message status
  Future<void> setMessageStatus({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required List<String> isSeenByList,
    required bool isGroupChat,
  }) async {
    if (isGroupChat) {
      if (!isSeenByList.contains(currentUserId)) {
        await _firestore
            .collection(Constants.groups)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageId)
            .update({
          Constants.isSeenBy: FieldValue.arrayUnion([currentUserId]),
        });
      }
    } else {
      final batch = _firestore.batch();

      final currentMsgRef = _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId);

      final contactMsgRef = _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageId);

      final currentLastMsgRef = _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID);

      final contactLastMsgRef = _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId);

      batch.update(currentMsgRef, {Constants.isSeen: true});
      batch.update(contactMsgRef, {Constants.isSeen: true});
      batch.update(currentLastMsgRef, {Constants.isSeen: true});
      batch.update(contactLastMsgRef, {Constants.isSeen: true});

      await batch.commit();
    }
  }

  // Delete message
  Future<void> deleteMessage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
    required bool isGroupChat,
    required bool deleteForEveryone,
  }) async {
    setLoading(true);

    if (isGroupChat) {
      final msgRef = _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId);

      await msgRef.update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });

      if (deleteForEveryone) {
        final groupData =
            await _firestore.collection(Constants.groups).doc(contactUID).get();
        final List<String> groupMembers =
            List<String>.from(groupData.data()![Constants.membersUIDs]);
        await msgRef.update({
          Constants.deletedBy: FieldValue.arrayUnion(groupMembers)
        });

        if (messageType != MessageEnum.text.name) {
          await deleteFileFromStorage(
            currentUserId: currentUserId,
            contactUID: contactUID,
            messageId: messageId,
            messageType: messageType,
          );
        }
      }
      setLoading(false);
    } else {
      final currentMsgRef = _firestore
          .collection(Constants.users)
          .doc(currentUserId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .doc(messageId);

      await currentMsgRef.update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });

      if (!deleteForEveryone) {
        setLoading(false);
        return;
      }

      final contactMsgRef = _firestore
          .collection(Constants.users)
          .doc(contactUID)
          .collection(Constants.chats)
          .doc(currentUserId)
          .collection(Constants.messages)
          .doc(messageId);

      await contactMsgRef.update({
        Constants.deletedBy: FieldValue.arrayUnion([currentUserId])
      });

      if (messageType != MessageEnum.text.name) {
        await deleteFileFromStorage(
          currentUserId: currentUserId,
          contactUID: contactUID,
          messageId: messageId,
          messageType: messageType,
        );
      }
      setLoading(false);
    }
  }

  // Delete file from storage
  Future<void> deleteFileFromStorage({
    required String currentUserId,
    required String contactUID,
    required String messageId,
    required String messageType,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
          '${Constants.chatFiles}/$messageType/$currentUserId/$contactUID/$messageId');
      await ref.delete();
    } catch (e) {
      // Optionally log error
    }
  }

  // Get last message stream
  Stream<QuerySnapshot> getLastMessageStream({
    required String userId,
    required String groupId,
  }) {
    return groupId.isNotEmpty
        ? _firestore
            .collection(Constants.groups)
            .where(Constants.membersUIDs, arrayContains: userId)
            .snapshots()
        : _firestore
            .collection(Constants.users)
            .doc(userId)
            .collection(Constants.chats)
            .snapshots();
  }

  // Helper function for file upload
  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(reference);
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      // Optionally log error
      return '';
    }
  }
}
