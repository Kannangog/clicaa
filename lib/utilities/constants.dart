class Constants {

  static const String landingScreen = '/landingScreen';
  static const String loginScreen = '/loginScreen';
  static const String otpScreen = '/otpScreen';
  static const String userInformationScreen = '/UserInformationScreen';
  static const String homeScreen = '/homeScreen';
  static const String chatScreen = '/chatScreen';
  static const String profileScreen = '/profileScreen';
  static const String settingsScreen = '/settingsScreen';
  static const String editProfileScreen = '/editProfileScreen';
  static const String searchScreen = '/searchScreen';
  static const String friendsScreen = '/friendsScreen';
  static const String friendRequestsScreen = '/friendRequestsScreen';
  static const String aboutScreen = '/aboutScreen';
  static const String privacyPolicyScreen = '/privacyPolicyScreen';
  static const String termsAndConditionsScreen = '/termsAndConditionsScreen';
  
  






  static const String uid = 'uid';
  static const String name = 'name';
  static const String image = 'image';
  static const String phoneNumber = 'phoneNumber';
  static const String token = 'token';
  static const String aboutMe = 'aboutMe';
  static const String lastSeen = 'lastSeen';
  static const String createdAt = 'createdAt';
  static const String isOnline = 'isOnline';
  static const String friendsUIDs = 'friendsUIDs';
  static const String friendRequestsUIDs = 'friendRequestsUIDs';
  static const String sentFriendRequestsUIDs = 'sentFriendRequestsUIDs';
  
  static const String verificationId = 'verificationId';
  static const String users = 'users';
  static const String userImages = 'userImages';
  static const String userModel = 'userModel';

  static const String contactName = 'contactName';
  static const String contactImage = 'contactImage';
  static const String groupID = 'groupID';


  static const String senderUID = 'senderUID'; 
  static const String senderName = 'senderName';
  static const String senderImage = 'senderImage';
  static const String contactUID = 'contactUID';
  static const String message = 'message';
  static const String messageType = 'messageType';
  static const String timeSent = 'timeSent';
  static const String messageId = 'messageId';
  static const String isSeen = 'isSeen';
  static const String repliedMessage = 'repliedMessage';
  static const String repliedTo = 'repliedTo';
  static const String repliedMessageType = 'repliedMessageType';
  static const String isMe = 'isMe';

  static const String lastMessage = 'lastMessage';
  static const String chats = 'chats';
  static const String messages = 'messages';
  static const String groups = 'groups';

}

enum FriendViewType{
  friends,
  friendRequests,
  groupView,
}
enum MessageEnum{
  text,
  image,
  video,
  audio,
}

// extension convertMessageEnumToString on String
extension MessageEnumExtension on String {
  MessageEnum toMessageEnum() {
    switch (this) {
      case 'text':
        return MessageEnum.text;
      case 'image':
        return MessageEnum.image;
      case 'video':
        return MessageEnum.video;
      case 'audio':
        return MessageEnum.audio;
      default:
        return MessageEnum.text;
    }
  }
  
}