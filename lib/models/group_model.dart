import 'package:clica/constants.dart';
import 'package:clica/enums/enums.dart';

class GroupModel {
  final String creatorUID;
  final String groupName;
  final String groupDescription;
  final String groupImage;
  final String groupId;
  final String lastMessage;
  final String senderUID;
  final MessageEnum messageType;
  final String messageId;
  final DateTime timeSent;
  final DateTime createdAt;
  final bool isPrivate;
  final bool editSettings;
  final bool approveMembers;
  final bool lockMessages;
  final bool requestToJoing;
  final List<String> membersUIDs;
  final List<String> adminsUIDs;
  final List<String> awaitingApprovalUIDs;

  GroupModel({
    required this.creatorUID,
    required this.groupName,
    required this.groupDescription,
    required this.groupImage,
    required this.groupId,
    required this.lastMessage,
    required this.senderUID,
    required this.messageType,
    required this.messageId,
    required this.timeSent,
    required this.createdAt,
    required this.isPrivate,
    required this.editSettings,
    required this.approveMembers,
    required this.lockMessages,
    required this.requestToJoing,
    required this.membersUIDs,
    required this.adminsUIDs,
    required this.awaitingApprovalUIDs,
  });

  Map<String, dynamic> toMap() {
    return {
      Constants.creatorUID: creatorUID,
      Constants.groupName: groupName,
      Constants.groupDescription: groupDescription,
      Constants.groupImage: groupImage,
      Constants.groupId: groupId,
      Constants.lastMessage: lastMessage,
      Constants.senderUID: senderUID,
      Constants.messageType: messageType.name,
      Constants.messageId: messageId,
      Constants.timeSent: timeSent.millisecondsSinceEpoch,
      Constants.createdAt: createdAt.millisecondsSinceEpoch,
      Constants.isPrivate: isPrivate,
      Constants.editSettings: editSettings,
      Constants.approveMembers: approveMembers,
      Constants.lockMessages: lockMessages,
      Constants.requestToJoing: requestToJoing,
      Constants.membersUIDs: membersUIDs,
      Constants.adminsUIDs: adminsUIDs,
      Constants.awaitingApprovalUIDs: awaitingApprovalUIDs,
    };
  }

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      creatorUID: map[Constants.creatorUID] ?? '',
      groupName: map[Constants.groupName] ?? '',
      groupDescription: map[Constants.groupDescription] ?? '',
      groupImage: map[Constants.groupImage] ?? '',
      groupId: map[Constants.groupId] ?? '',
      lastMessage: map[Constants.lastMessage] ?? '',
      senderUID: map[Constants.senderUID] ?? '',
      messageType: (map[Constants.messageType] as String?)?.toMessageEnum() ?? MessageEnum.text,
      messageId: map[Constants.messageId] ?? '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(
          map[Constants.timeSent] ?? DateTime.now().millisecondsSinceEpoch),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map[Constants.createdAt] ?? DateTime.now().millisecondsSinceEpoch),
      isPrivate: map[Constants.isPrivate] ?? false,
      editSettings: map[Constants.editSettings] ?? false,
      approveMembers: map[Constants.approveMembers] ?? false,
      lockMessages: map[Constants.lockMessages] ?? false,
      requestToJoing: map[Constants.requestToJoing] ?? false,
      membersUIDs: List<String>.from(map[Constants.membersUIDs] ?? []),
      adminsUIDs: List<String>.from(map[Constants.adminsUIDs] ?? []),
      awaitingApprovalUIDs:
          List<String>.from(map[Constants.awaitingApprovalUIDs] ?? []),
    );
  }

  GroupModel copyWith({
    String? creatorUID,
    String? groupName,
    String? groupDescription,
    String? groupImage,
    String? groupId,
    String? lastMessage,
    String? senderUID,
    MessageEnum? messageType,
    String? messageId,
    DateTime? timeSent,
    DateTime? createdAt,
    bool? isPrivate,
    bool? editSettings,
    bool? approveMembers,
    bool? lockMessages,
    bool? requestToJoing,
    List<String>? membersUIDs,
    List<String>? adminsUIDs,
    List<String>? awaitingApprovalUIDs,
  }) {
    return GroupModel(
      creatorUID: creatorUID ?? this.creatorUID,
      groupName: groupName ?? this.groupName,
      groupDescription: groupDescription ?? this.groupDescription,
      groupImage: groupImage ?? this.groupImage,
      groupId: groupId ?? this.groupId,
      lastMessage: lastMessage ?? this.lastMessage,
      senderUID: senderUID ?? this.senderUID,
      messageType: messageType ?? this.messageType,
      messageId: messageId ?? this.messageId,
      timeSent: timeSent ?? this.timeSent,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
      editSettings: editSettings ?? this.editSettings,
      approveMembers: approveMembers ?? this.approveMembers,
      lockMessages: lockMessages ?? this.lockMessages,
      requestToJoing: requestToJoing ?? this.requestToJoing,
      membersUIDs: membersUIDs ?? this.membersUIDs,
      adminsUIDs: adminsUIDs ?? this.adminsUIDs,
      awaitingApprovalUIDs: awaitingApprovalUIDs ?? this.awaitingApprovalUIDs,
    );
  }

  static GroupModel empty() {
    return GroupModel(
      creatorUID: '',
      groupName: '',
      groupDescription: '',
      groupImage: '',
      groupId: '',
      lastMessage: '',
      senderUID: '',
      messageType: MessageEnum.text,
      messageId: '',
      timeSent: DateTime.fromMillisecondsSinceEpoch(0),
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      isPrivate: false,
      editSettings: false,
      approveMembers: false,
      lockMessages: false,
      requestToJoing: false,
      membersUIDs: [],
      adminsUIDs: [],
      awaitingApprovalUIDs: [],
    );
  }
}