// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:clica/models/user_model.dart';
import 'package:clica/constants.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;

  bool get isLoading => _isLoading;
  bool get isSuccessful => _isSuccessful;
  String? get uid => _uid;
  String? get phoneNumber => _phoneNumber;
  UserModel? get userModel => _userModel;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<bool> checkAuthenticationState() async {
    bool isSignedIn = false;
    await Future.delayed(const Duration(seconds: 2));

    if (_auth.currentUser != null) {
      _uid = _auth.currentUser!.uid;
      await getUserDataFromFireStore();
      await saveUserDataToSharedPreferences();
      notifyListeners();
      isSignedIn = true;
    } else {
      isSignedIn = false;
    }
    return isSignedIn;
  }

  Future<bool> checkUserExists() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    return documentSnapshot.exists;
  }

  Future<void> updateUserStatus({required bool value}) async {
    await _firestore
        .collection(Constants.users)
        .doc(_auth.currentUser!.uid)
        .update({Constants.isOnline: value});
  }

  Future<void> getUserDataFromFireStore() async {
    DocumentSnapshot documentSnapshot =
        await _firestore.collection(Constants.users).doc(_uid).get();
    final data = documentSnapshot.data();
    if (data != null) {
      _userModel = UserModel.fromMap(data as Map<String, dynamic>);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<void> saveUserDataToSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (_userModel != null) {
      await sharedPreferences.setString(
          Constants.userModel, jsonEncode(_userModel!.toMap()));
    }
  }

  Future<void> getUserDataFromSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String userModelString =
        sharedPreferences.getString(Constants.userModel) ?? '';
    if (userModelString.isNotEmpty) {
      _userModel = UserModel.fromMap(jsonDecode(userModelString));
      _uid = _userModel!.uid;
      notifyListeners();
    }
  }

  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential).then((value) async {
          _uid = value.user!.uid;
          _phoneNumber = value.user!.phoneNumber;
          _isSuccessful = true;
          _isLoading = false;
          notifyListeners();
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        _isSuccessful = false;
        _isLoading = false;
        notifyListeners();
        showSnackBar(context, e.toString());
      },
      codeSent: (String verificationId, int? resendToken) async {
        _isLoading = false;
        notifyListeners();
        Navigator.of(context).pushNamed(
          Constants.otpScreen,
          arguments: {
            Constants.verificationId: verificationId,
            Constants.phoneNumber: phoneNumber,
          },
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  Future<void> verifyOTPCode({
    required String verificationId,
    required String otpCode,
    required BuildContext context,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpCode,
    );

    try {
      final value = await _auth.signInWithCredential(credential);
      _uid = value.user!.uid;
      _phoneNumber = value.user!.phoneNumber;
      _isSuccessful = true;
      _isLoading = false;
      onSuccess();
      notifyListeners();
    } catch (e) {
      _isSuccessful = false;
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, e.toString());
    }
  }

  Future<String> storeFileToStorage({
    required File file,
    required String reference,
  }) async {
    TaskSnapshot task = await _storage.ref(reference).putFile(file);
    return await task.ref.getDownloadURL();
  }

  void saveUserDataToFireStore({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        userModel = userModel.copyWith(
          image: await storeFileToStorage(
            file: fileImage,
            reference: '${Constants.userImages}/${userModel.uid}',
          ),
        );
      }

      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .set(userModel.toMap());

      _userModel = userModel;
      _uid = userModel.uid;
      _isLoading = false;
      await saveUserDataToSharedPreferences();
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  Future<void> updateUserProfile({
    required UserModel userModel,
    required File? fileImage,
    required Function onSuccess,
    required Function(String) onFail,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (fileImage != null) {
        userModel = userModel.copyWith(
          image: await storeFileToStorage(
            file: fileImage,
            reference: '${Constants.userImages}/${userModel.uid}',
          ),
        );
      }

      await _firestore
          .collection(Constants.users)
          .doc(userModel.uid)
          .update(userModel.toMap());

      _userModel = userModel;
      _isLoading = false;
      await saveUserDataToSharedPreferences();
      onSuccess();
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      onFail(e.toString());
    }
  }

  Stream<DocumentSnapshot> userStream({required String userID}) {
    return _firestore.collection(Constants.users).doc(userID).snapshots();
  }

  Stream<QuerySnapshot> getAllUsersStream({required String userID}) {
    return _firestore
        .collection(Constants.users)
        .where(Constants.uid, isNotEqualTo: userID)
        .snapshots();
  }

  Future<void> sendFriendRequest({required String friendID}) async {
    try {
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendRequestsUIDs: FieldValue.arrayUnion([_uid]),
      });
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayUnion([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.clear();
    notifyListeners();
  }

  Future<void> removeFriend({required String friendID}) async {
    try {
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendsUIDs: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }
  Future<void> cancleFriendRequest({required String friendID}) async {
    try {
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<void> acceptFriendRequest({required String friendID}) async {
    try {
      await _firestore.collection(Constants.users).doc(friendID).update({
        Constants.friendsUIDs: FieldValue.arrayUnion([_uid]),
        Constants.sentFriendRequestsUIDs: FieldValue.arrayRemove([_uid]),
      });
      await _firestore.collection(Constants.users).doc(_uid).update({
        Constants.friendsUIDs: FieldValue.arrayUnion([friendID]),
        Constants.friendRequestsUIDs: FieldValue.arrayRemove([friendID]),
      });
    } on FirebaseException catch (e) {
      print(e);
    }
  }

  Future<List<UserModel>> getFriendsList(String uid, List<String> groupMembersUIDs) async {
    try {
      List<UserModel> friends = [];
      var userSnapshot = await _firestore.collection(Constants.users).doc(uid).get();
      List<String> friendsUIDs = List<String>.from(userSnapshot.data()![Constants.friendsUIDs]);

      for (String friendID in friendsUIDs) {
        if (!groupMembersUIDs.contains(friendID)) {
          var friendSnapshot = await _firestore.collection(Constants.users).doc(friendID).get();
          friends.add(UserModel.fromMap(friendSnapshot.data()!));
        }
      }
      return friends;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<UserModel>> getFriendRequestsList({required String uid, required String groupId}) async {
    try {
      List<UserModel> friendRequests = [];
      var userSnapshot = await _firestore.collection(Constants.users).doc(uid).get();
      List<String> requestsUIDs = List<String>.from(userSnapshot.data()![Constants.friendRequestsUIDs]);

      for (String requestID in requestsUIDs) {
        var requestSnapshot = await _firestore.collection(Constants.users).doc(requestID).get();
        friendRequests.add(UserModel.fromMap(requestSnapshot.data()!));
      }
      return friendRequests;
    } catch (e) {
      print(e);
      return [];
    }
  }
}