import 'dart:io';
import 'dart:typed_data';
import 'package:clica/enums/enums.dart';
import 'package:clica/models/group_model.dart';
import 'package:clica/models/message_model.dart';
import 'package:clica/models/user_model.dart';
import 'package:clica/constants.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupProvider extends ChangeNotifier {
  bool _isSloading = false;
  GroupModel _groupModel = GroupModel(
    creatorUID: '',
    groupName: '',
    groupDescription: '',
    groupImage: '',
    groupId: '',
    lastMessage: '',
    senderUID: '',
    messageType: MessageEnum.text,
    messageId: '',
    timeSent: DateTime.now(),
    createdAt: DateTime.now(),
    isPrivate: true,
    editSettings: true,
    approveMembers: false,
    lockMessages: false,
    requestToJoing: false,
    membersUIDs: [],
    adminsUIDs: [],
    awaitingApprovalUIDs: [],
  );
  final List<UserModel> _groupMembersList = [];
  final List<UserModel> _groupAdminsList = [];

  bool get isSloading => _isSloading;
  GroupModel get groupModel => _groupModel;
  List<UserModel> get groupMembersList => _groupMembersList;
  List<UserModel> get groupAdminsList => _groupAdminsList;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setIsSloading({required bool value}) {
    _isSloading = value;
    notifyListeners();
  }

  void setEditSettings({required bool value}) {
    _groupModel = _groupModel.copyWith(editSettings: value);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setApproveNewMembers({required bool value}) {
    _groupModel = _groupModel.copyWith(approveMembers: value);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setRequestToJoin({required bool value}) {
    _groupModel = _groupModel.copyWith(requestToJoing: value);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void setLockMessages({required bool value}) {
    _groupModel = _groupModel.copyWith(lockMessages: value);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  Future<void> updateGroupDataInFireStore() async {
    try {
      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupId)
          .update(_groupModel.toMap());
    } catch (e) {
      debugPrint('Error updating group data: ${e.toString()}');
    }
  }

  void addMemberToGroup({required UserModel groupMember}) {
    _groupMembersList.add(groupMember);
    _groupModel = _groupModel.copyWith(
      membersUIDs: [..._groupModel.membersUIDs, groupMember.uid]
    );
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void addMemberToAdmins({required UserModel groupAdmin}) {
    _groupAdminsList.add(groupAdmin);
    _groupModel = _groupModel.copyWith(
      adminsUIDs: [..._groupModel.adminsUIDs, groupAdmin.uid]
    );
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  Future<void> setGroupModel({required GroupModel groupModel}) async {
    _groupModel = groupModel;
    await updateGroupMembersList();
    await updateGroupAdminsList();
    notifyListeners();
  }

  Future<void> removeGroupMember({required UserModel groupMember}) async {
    _groupMembersList.remove(groupMember);
    _groupAdminsList.removeWhere((e) => e.uid == groupMember.uid);
    
    final newMembers = _groupModel.membersUIDs.where((uid) => uid != groupMember.uid).toList();
    final newAdmins = _groupModel.adminsUIDs.where((uid) => uid != groupMember.uid).toList();
    
    _groupModel = _groupModel.copyWith(
      membersUIDs: newMembers,
      adminsUIDs: newAdmins,
    );
    
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  void removeGroupAdmin({required UserModel groupAdmin}) {
    _groupAdminsList.remove(groupAdmin);
    final newAdmins = _groupModel.adminsUIDs.where((uid) => uid != groupAdmin.uid).toList();
    _groupModel = _groupModel.copyWith(adminsUIDs: newAdmins);
    notifyListeners();
    if (_groupModel.groupId.isEmpty) return;
    updateGroupDataInFireStore();
  }

  Future<List<UserModel>> getGroupMembersDataFromFirestore({
    required bool isAdmin,
  }) async {
    try {
      List<UserModel> membersData = [];
      List<String> membersUIDs = isAdmin 
          ? _groupModel.adminsUIDs 
          : _groupModel.membersUIDs;

      for (var uid in membersUIDs) {
        var user = await _firestore.collection(Constants.users).doc(uid).get();
        if (user.exists) {
          membersData.add(UserModel.fromMap(user.data()!));
        }
      }

      return membersData;
    } catch (e) {
      debugPrint('Error getting group members: ${e.toString()}');
      return [];
    }
  }

  Future<void> updateGroupMembersList() async {
    try {
      _groupMembersList.clear();
      _groupMembersList.addAll(
        await getGroupMembersDataFromFirestore(isAdmin: false)
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating members list: ${e.toString()}');
    }
  }

  Future<void> updateGroupAdminsList() async {
    try {
      _groupAdminsList.clear();
      _groupAdminsList.addAll(
        await getGroupMembersDataFromFirestore(isAdmin: true)
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating admins list: ${e.toString()}');
    }
  }

  Future<void> clearGroupMembersList() async {
    _groupMembersList.clear();
    _groupAdminsList.clear();
    _groupModel = GroupModel(
      creatorUID: '',
      groupName: '',
      groupDescription: '',
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.now(),
      createdAt: DateTime.now(),
      isPrivate: true,
      editSettings: true,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
    notifyListeners();
  }

  List<String> getGroupMembersUIDs() {
    return _groupMembersList.map((e) => e.uid).toList();
  }

  List<String> getGroupAdminsUIDs() {
    return _groupAdminsList.map((e) => e.uid).toList();
  }

  Stream<DocumentSnapshot> groupStream({required String groupId}) {
    return _firestore.collection(Constants.groups).doc(groupId).snapshots();
  }

  Stream<List<DocumentSnapshot>> streamGroupMembersData({required List<String> membersUIDs}) {
    return Stream.fromFuture(Future.wait<DocumentSnapshot>(
      membersUIDs.map<Future<DocumentSnapshot>>((uid) async {
        return await _firestore.collection(Constants.users).doc(uid).get();
      }),
    ));
  }

  Future<void> createGroup({
    required GroupModel newGroupModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    setIsSloading(value: true);

    try {
      var groupId = const Uuid().v4();
      GroupModel updatedGroupModel = newGroupModel.copyWith(groupId: groupId);

      if (fileImage != null) {
        final String imageUrl = await storeFileToStorage(
            file: fileImage, reference: '${Constants.groupImages}/$groupId');
        updatedGroupModel = updatedGroupModel.copyWith(groupImage: imageUrl);
      }

      updatedGroupModel = updatedGroupModel.copyWith(
        adminsUIDs: [
          updatedGroupModel.creatorUID,
          ...getGroupAdminsUIDs()
        ],
        membersUIDs: [
          updatedGroupModel.creatorUID,
          ...getGroupMembersUIDs()
        ],
      );

      setGroupModel(groupModel: updatedGroupModel);
      await _firestore
          .collection(Constants.groups)
          .doc(groupId)
          .set(updatedGroupModel.toMap());

      setIsSloading(value: false);
      onSuccess();
    } catch (e) {
      setIsSloading(value: false);
      onFail(e.toString());
    }
  }

  Stream<List<GroupModel>> getPrivateGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.membersUIDs, arrayContains: userId)
        .where(Constants.isPrivate, isEqualTo: true)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }
      return groups;
    });
  }

  Stream<List<GroupModel>> getPublicGroupsStream({required String userId}) {
    return _firestore
        .collection(Constants.groups)
        .where(Constants.isPrivate, isEqualTo: false)
        .snapshots()
        .asyncMap((event) {
      List<GroupModel> groups = [];
      for (var group in event.docs) {
        groups.add(GroupModel.fromMap(group.data()));
      }
      return groups;
    });
  }

  void changeGroupType() {
    _groupModel = _groupModel.copyWith(isPrivate: !_groupModel.isPrivate);
    notifyListeners();
    updateGroupDataInFireStore();
  }

  Future<void> sendRequestToJoinGroup({
    required String groupId,
    required String uid,
    required String groupName,
    required String groupImage,
  }) async {
    try {
      await _firestore.collection(Constants.groups).doc(groupId).update({
        Constants.awaitingApprovalUIDs: FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      debugPrint('Error sending join request: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> acceptRequestToJoinGroup({
    required String groupId,
    required String friendID,
  }) async {
    try {
      await _firestore.collection(Constants.groups).doc(groupId).update({
        Constants.membersUIDs: FieldValue.arrayUnion([friendID]),
        Constants.awaitingApprovalUIDs: FieldValue.arrayRemove([friendID])
      });

      _groupModel = _groupModel.copyWith(
        awaitingApprovalUIDs: _groupModel.awaitingApprovalUIDs.where((id) => id != friendID).toList(),
        membersUIDs: [..._groupModel.membersUIDs, friendID],
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error accepting join request: ${e.toString()}');
      rethrow;
    }
  }

  bool isSenderOrAdmin({required MessageModel message, required String uid}) {
    return message.senderUID == uid || _groupModel.adminsUIDs.contains(uid);
  }

  Future<void> exitGroup({
    required String uid,
  }) async {
    try {
      bool isAdmin = _groupModel.adminsUIDs.contains(uid);

      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupId)
          .update({
        Constants.membersUIDs: FieldValue.arrayRemove([uid]),
        Constants.adminsUIDs: isAdmin 
            ? FieldValue.arrayRemove([uid]) 
            : _groupModel.adminsUIDs,
      });

      _groupMembersList.removeWhere((element) => element.uid == uid);
      final newMembers = _groupModel.membersUIDs.where((id) => id != uid).toList();
      
      if (isAdmin) {
        _groupAdminsList.removeWhere((element) => element.uid == uid);
        final newAdmins = _groupModel.adminsUIDs.where((id) => id != uid).toList();
        _groupModel = _groupModel.copyWith(
          membersUIDs: newMembers,
          adminsUIDs: newAdmins,
        );
      } else {
        _groupModel = _groupModel.copyWith(membersUIDs: newMembers);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error exiting group: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> updateGroupInfo({
    required String name,
    required String description,
    Uint8List? imageBytes,
  }) async {
    try {
      String? imageUrl;
      
      if (imageBytes != null) {
        final Reference ref = FirebaseStorage.instance
            .ref()
            .child('${Constants.groupImages}/${_groupModel.groupId}');
        await ref.putData(imageBytes);
        imageUrl = await ref.getDownloadURL();
      }

      _groupModel = _groupModel.copyWith(
        groupName: name,
        groupDescription: description,
        groupImage: imageUrl ?? _groupModel.groupImage,
      );

      await _firestore
          .collection(Constants.groups)
          .doc(_groupModel.groupId)
          .update({
        Constants.groupName: name,
        Constants.groupDescription: description,
        if (imageUrl != null) Constants.groupImage: imageUrl,
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating group info: ${e.toString()}');
      rethrow;
    }
  }

  Future<void> deleteGroup() async {
    try {
      // First verify we have a valid group ID
      if (_groupModel.groupId.isEmpty) {
        throw Exception('Cannot delete group - no group ID set');
      }

      // Store group ID and image locally since we'll clear the model
      final groupId = _groupModel.groupId;
      final groupImage = _groupModel.groupImage;

      // Delete all messages
      final messagesQuery = await _firestore
          .collection(Constants.groups)
          .doc(groupId)
          .collection(Constants.messages)
          .get();

      final messageDeletions = messagesQuery.docs.map((doc) => doc.reference.delete());
      await Future.wait(messageDeletions);

      // Delete all requests (if this collection exists)
      try {
        final requestsQuery = await _firestore
            .collection(Constants.groups)
            .doc(groupId)
            .collection(Constants.requests)
            .get();

        final requestDeletions = requestsQuery.docs.map((doc) => doc.reference.delete());
        await Future.wait(requestDeletions);
      } catch (e) {
        debugPrint('No requests collection to delete: ${e.toString()}');
      }

      // Delete group image if it exists
      if (groupImage.isNotEmpty) {
        try {
          final Reference ref = FirebaseStorage.instance.refFromURL(groupImage);
          await ref.delete();
        } catch (e) {
          debugPrint('Failed to delete group image: ${e.toString()}');
        }
      }

      // Finally delete the group document
      await _firestore.collection(Constants.groups).doc(groupId).delete();

      // Clear local state
      clearGroupMembersList();
      notifyListeners();

    } catch (e) {
      debugPrint('Failed to delete group: ${e.toString()}');
      rethrow;
    }
  }
}