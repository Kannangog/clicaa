import 'package:clica/constants.dart';

class UserModel {
  final String uid;
  final String name;
  final String phoneNumber;
  final String image;
  final String token;
  final String aboutMe;
  final String lastSeen;
  final String createdAt;
  final bool isOnline;
  final List<String> friendsUIDs;
  final List<String> friendRequestsUIDs;
  final List<String> sentFriendRequestsUIDs;

  UserModel({
    required this.uid,
    required this.name,
    required this.phoneNumber,
    required this.image,
    required this.token,
    required this.aboutMe,
    required this.lastSeen,
    required this.createdAt,
    required this.isOnline,
    required this.friendsUIDs,
    required this.friendRequestsUIDs,
    required this.sentFriendRequestsUIDs,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map[Constants.uid] ?? '',
      name: map[Constants.name] ?? '',
      phoneNumber: map[Constants.phoneNumber] ?? '',
      image: map[Constants.image] ?? '',
      token: map[Constants.token] ?? '',
      aboutMe: map[Constants.aboutMe] ?? '',
      lastSeen: map[Constants.lastSeen] ?? '',
      createdAt: map[Constants.createdAt] ?? '',
      isOnline: map[Constants.isOnline] ?? false,
      friendsUIDs: List<String>.from(map[Constants.friendsUIDs] ?? []),
      friendRequestsUIDs:
          List<String>.from(map[Constants.friendRequestsUIDs] ?? []),
      sentFriendRequestsUIDs:
          List<String>.from(map[Constants.sentFriendRequestsUIDs] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.phoneNumber: phoneNumber,
      Constants.image: image,
      Constants.token: token,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.createdAt: createdAt,
      Constants.isOnline: isOnline,
      Constants.friendsUIDs: friendsUIDs,
      Constants.friendRequestsUIDs: friendRequestsUIDs,
      Constants.sentFriendRequestsUIDs: sentFriendRequestsUIDs,
    };
  }

  UserModel copyWith({
    String? name,
    String? aboutMe,
    String? image,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phoneNumber: phoneNumber,
      image: image ?? this.image,
      token: token,
      aboutMe: aboutMe ?? this.aboutMe,
      lastSeen: lastSeen,
      createdAt: createdAt,
      isOnline: isOnline,
      friendsUIDs: friendsUIDs,
      friendRequestsUIDs: friendRequestsUIDs,
      sentFriendRequestsUIDs: sentFriendRequestsUIDs,
    );
  }
}