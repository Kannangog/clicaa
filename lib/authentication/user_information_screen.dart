import 'dart:io';
import 'package:clica/models/user_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/constants.dart';
import 'package:clica/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({
    super.key,
    required this.enableUpdatingInformation,
  });

  final bool enableUpdatingInformation;

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeUserData();
  }

  void _initializeUserData() {
    final authProvider = context.read<AuthenticationProvider>();
    if (widget.enableUpdatingInformation && authProvider.userModel != null) {
      _nameController.text = authProvider.userModel!.name;
      userImage = authProvider.userModel!.image;
      _aboutMeController.text = authProvider.userModel!.aboutMe;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }

  Future<File?> pickImage({
    required BuildContext context,
    required bool fromCamera,
    required Function(String) onFail,
  }) async {
    try {
      final image = await ImagePicker().pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );
      return image != null ? File(image.path) : null;
    } catch (e) {
      onFail('Failed to pick image: $e');
      return null;
    }
  }

  Future<void> cropImage(String? filePath) async {
    if (filePath != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: filePath,
        maxHeight: 800,
        maxWidth: 800,
        compressQuality: 90,
      );
      if (croppedFile != null) {
        setState(() {
          finalFileImage = File(croppedFile.path);
        });
      }
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () => _selectImage(true),
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () => _selectImage(false),
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImage(bool fromCamera) async {
    final image = await pickImage(
      context: context,
      fromCamera: fromCamera,
      onFail: (message) => showSnackBar(context, message),
    );

    if (image != null) {
      await cropImage(image.path);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: AppBarBackButton(
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          widget.enableUpdatingInformation
              ? 'Update Profile'
              : 'User Information',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DisplayUserImage(
                  finalFileImage: finalFileImage,
                  userImage: userImage.isNotEmpty ? userImage : null,
                  radius: 60,
                  onPressed: showBottomSheet,
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _aboutMeController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'About me',
                    labelText: 'About me',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildSubmitButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final authProvider = context.watch<AuthenticationProvider>();
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: MaterialButton(
        onPressed: authProvider.isLoading
            ? null
            : () {
                if (_nameController.text.isEmpty ||
                    _nameController.text.length < 3) {
                  showSnackBar(context, 'Name must be at least 3 characters');
                  return;
                }
                _saveUserData();
              },
        child: authProvider.isLoading
            ? const CircularProgressIndicator(color: Colors.orangeAccent)
            : Text(
                widget.enableUpdatingInformation ? 'Update Profile' : 'Continue',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5),
              ),
      ),
    );
  }

  void _saveUserData() async {
    final authProvider = context.read<AuthenticationProvider>();
    final userModel = authProvider.userModel;

    if (widget.enableUpdatingInformation && userModel != null) {
      final updatedUser = userModel.copyWith(
        name: _nameController.text.trim(),
        aboutMe: _aboutMeController.text.trim().isEmpty
            ? 'Hey there, I\'m using clickup'
            : _aboutMeController.text.trim(),
      );

      await authProvider.updateUserProfile(
        userModel: updatedUser,
        fileImage: finalFileImage,
        onSuccess: () => Navigator.of(context).pop(),
        onFail: (error) => showSnackBar(context, 'Update failed: $error'),
      );
    } else {
      final newUser = UserModel(
        uid: authProvider.uid!,
        name: _nameController.text.trim(),
        phoneNumber: authProvider.phoneNumber ?? '',
        image: '',
        token: '',
        aboutMe: _aboutMeController.text.trim().isEmpty
            ? 'Hey there, I\'m using clica'
            : _aboutMeController.text.trim(),
        lastSeen: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
        isOnline: true,
        friendsUIDs: [],
        friendRequestsUIDs: [],
        sentFriendRequestsUIDs: [],
      );

      authProvider.saveUserDataToFireStore(
        userModel: newUser,
        fileImage: finalFileImage,
        onSuccess: () => Navigator.of(context).pushNamedAndRemoveUntil(
          Constants.homeScreen, (route) => false),
        onFail: (error) => showSnackBar(context, 'Save failed: $error'),
      );
    }
  }
}