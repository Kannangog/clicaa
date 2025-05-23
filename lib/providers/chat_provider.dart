import 'package:clica/models/last_message_model.dart';
import 'package:clica/models/message_model.dart';
import 'package:clica/models/message_reply_model.dart';
import 'package:clica/models/user_model.dart';
import 'package:clica/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatProvider extends ChangeNotifier{
  bool _isLoading = false;
  MessageReplyModel? _messageReplyModel;

  bool get isLoading => _isLoading;
  MessageReplyModel? get messageReplyModel => _messageReplyModel;

  void setIsLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  void setMessageReplyModel(MessageReplyModel? messageReply) {
    _messageReplyModel = messageReply;
    notifyListeners();
  }

  // firebase initialization
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // send text messgae to firestore
  Future<void> sendTextMessage({
    required UserModel sender,
    required String contactUID,
    required String contactName,
    required String contactImage,
    required String message,
    required MessageEnum messageType,
    required String groupId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    try {
      var messageId = const Uuid().v4();

      //1. check if its a message reply and add the replied message to the message
      String repliedMessage = _messageReplyModel?.message ?? '';
      String repliedTo = _messageReplyModel == null ? '' : _messageReplyModel!.isMe ? 'You':_messageReplyModel!.senderName;
      MessageEnum repliedMessageType = _messageReplyModel?.messageType ?? MessageEnum.text;
      
      //2. update/set the messagemodel
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
      );


      //3. check if its a group message and send to group else send to contact
      if(groupId.isNotEmpty){
        // handle group message

      }else{
        // handle contact message
        await handleContactMessage(
          messageModel:messageModel,
          contactUID: contactUID,
          contactName:contactName,
          contactImage:contactImage,
          onSuccess: onSuccess,
          onError: onError,
        );
        // set message reply model to null
        setMessageReplyModel(null);

      }


    } catch (e) {
      onError(e.toString());
    }
  }
  
  Future<void> handleContactMessage(
    {required MessageModel messageModel, 
    required String contactUID, 
    required String contactName, 
    required String contactImage, 
    required Function onSuccess, 
    required Function(String p1) onError,}) async{
     try{
      //0. contact messageModel
      final contactMessageModel = messageModel.copyWith(
        userId: messageModel.senderUID,
      );
       //1. initialize last message for the sender
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

      //2. initialize last message for the contact
      final contactLastMessage = senderLastMessage.copyWith(
        contactUID: messageModel.senderUID,
        contactName: messageModel.senderName,
        contactImage: messageModel.senderImage,
      );

      // run transaction
      await _firestore.runTransaction((transaction) async {
        //3. send message to sender firestore location
        transaction.set(
          _firestore
            .collection(Constants.users)
            .doc(messageModel.senderUID)
            .collection(Constants.chats)
            .doc(contactUID)
            .collection(Constants.messages)
            .doc(messageModel.messageId),
          messageModel.toMap(),
        );  
      //4. send message to contact firestore location
        transaction.set(
          _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(messageModel.senderUID)
            .collection(Constants.messages)
            .doc(messageModel.messageId),
          contactMessageModel.toMap(),
        );
        
        //5. send last message to sender firestore location
        transaction.set(
          _firestore
            .collection(Constants.users)
            .doc(messageModel.senderUID)
            .collection(Constants.chats)
            .doc(contactUID),
          senderLastMessage.toMap(),
        );

        //6. send last message to contact firestore location
        transaction.set(
          _firestore
            .collection(Constants.users)
            .doc(contactUID)
            .collection(Constants.chats)
            .doc(messageModel.senderUID),
          contactLastMessage.toMap(),
        );
      });
      //7. call onSuccess
      onSuccess();

     }on FirebaseException catch(e){
       onError(e.message.toString());
    } catch(e){
       onError(e.toString());
     }
  
  }

  // get chatslist stream
  Stream<List<LastMessageModel>> getChatsListStream(String userId) {
    return _firestore
        .collection(Constants.users)
        .doc(userId)
        .collection(Constants.chats)
        .orderBy(Constants.timeSent, descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return LastMessageModel.fromMap(doc.data());
          }).toList();
        });
  }
  // stream messages from chat collection
  Stream<List<MessageModel>> getMessagesStream({
    required String userId, 
    required String contactUID ,
    required String isGroup,
    }) {
      //1. check if its a group message
      if(isGroup.isNotEmpty){
        return _firestore
          .collection(Constants.groups)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return MessageModel.fromMap(doc.data());
            }).toList();
          });
    }else {
      //2. handle contact message
        return _firestore
          .collection(Constants.users)
          .doc(userId)
          .collection(Constants.chats)
          .doc(contactUID)
          .collection(Constants.messages)
          .orderBy(Constants.timeSent, descending: false)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return MessageModel.fromMap(doc.data());
            }).toList();
          });
    }
  }
}