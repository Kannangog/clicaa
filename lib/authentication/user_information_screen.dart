import 'dart:io';
import 'package:clica/models/user_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/constants.dart';
import 'package:clica/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// ***********  ✨ Windsurf Command 🌟  ************
class UserInformationScreen extends StatefulWidget {
const UserInformationScreen({super.key, required this.enableUpdatingInformation});

final bool enableUpdatingInformation;

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  // final RoundedLoadingButtonController _btnController =
  //     RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutMeController = TextEditingController();
  File? finalFileImage;
  String userImage = '';

  @override
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.read<AuthenticationProvider>();
    // If updating, prefill fields with current user data
    if (widget.enableUpdatingInformation && authProvider.userModel != null) {
      _nameController.text = authProvider.userModel!.name;
      userImage = authProvider.userModel!.image;
      _aboutMeController.text = authProvider.userModel!.aboutMe;
    }
  }
  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthenticationProvider>();
    // If updating, prefill fields with current user data
    if (widget.enableUpdatingInformation && authProvider.userModel != null) {
      _nameController.text = authProvider.userModel!.name;
      userImage = authProvider.userModel!.image;
      _aboutMeController.text = authProvider.userModel!.aboutMe;
    }
  }
  @override
  @override
  void dispose() {
    //_btnController.stop();
    _nameController.dispose();
    _aboutMeController.dispose();
    super.dispose();
  }
  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      context,
      fromCamera: fromCamera,
      onFail: (String message) {
        showSnackBar(context, message);
      },
    );

    // crop image
    await cropImage(finalFileImage?.path);

    popContext();
  }

  popContext() {
    Navigator.pop(context);
  }

  Future<void> cropImage(filePath) async {
    if (filePath != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
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
              onTap: () {
                selectImage(true);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
            ),
            ListTile(
              onTap: () {
                selectImage(false);
              },
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      leading: AppBarBackButton(
        onPressed: () {
        Navigator.of(context).pop();
        },
      ),
      centerTitle: true,
      title: const Text('User Information'),
      ),
      body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20.0,
        ),
        child: Column(
        children: [
          DisplayUserImage(
          finalFileImage: finalFileImage,
          userImage: userImage.isNotEmpty ? userImage : null,
          radius: 60,
          onPressed: () {
            showBottomSheet();
          },
          ),
          const SizedBox(height: 30),
          TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            labelText: 'Enter your name',
            border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
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
            borderRadius: BorderRadius.all(
              Radius.circular(8),
            ),
            ),
          ),
          ),
          const SizedBox(height: 40),
          Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(25),
          ),
          child: MaterialButton(
            onPressed: context.read<AuthenticationProvider>().isLoading
              ? null
              : () {
                if (_nameController.text.isEmpty ||
                  _nameController.text.length < 3) {
                showSnackBar(context, 'Please enter your name');
                return;
                }
                if (_aboutMeController.text.isEmpty) {
                showSnackBar(context, 'Please enter about me');
                return;
                }
                // save user data to firestore
                saveUserDataToFireStore();
              },
            child: context.watch<AuthenticationProvider>().isLoading
              ? const CircularProgressIndicator(
                color: Colors.orangeAccent,
              )
              : const Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5),
              ),
          ),
          ),
        ],
        ),
      ),
      ),
    );
  }

  // save user data to firestore
  void saveUserDataToFireStore() async {
    final authProvider = context.read<AuthenticationProvider>();

    if (authProvider.uid == null) {
      showSnackBar(context, 'User information is incomplete.');
      return;
    }
    // Only require phone number if not updating information
    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: _nameController.text.trim(),
      phoneNumber: authProvider.phoneNumber ?? '', // Use empty string if updating and phoneNumber is null
      image: '',
      token: '',
      aboutMe: _aboutMeController.text.trim().isEmpty ? 'Hey there, I\'m using clica' : _aboutMeController.text.trim(),
      lastSeen: '',
      createdAt: '',
      isOnline: true,
      friendsUIDs: [],
      friendRequestsUIDs: [],
      sentFriendRequestsUIDs: [], profileimage: '',
    );

    authProvider.saveUserDataToFireStore(
      userModel: userModel,
      fileImage: finalFileImage,
      onSuccess: () async {
        // save user data to shared preferences
        await authProvider.saveUserDataToSharedPreferences();

        navigateToHomeScreen();
      },
      onFail: () async {
        showSnackBar(context, 'Failed to save user data');
      },
    );
  }

  void navigateToHomeScreen() {
    // navigate to home screen and remove all previous screens
    Navigator.of(context).pushNamedAndRemoveUntil(
      Constants.homeScreen,
      (route) => false,
    );
  }
}