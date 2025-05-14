import 'dart:io';
import 'package:clica/models/user_model.dart';
import 'package:clica/providers/authentication_provider.dart';
import 'package:clica/utilities/constants.dart';
import 'package:clica/widgets/display_user_image.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:clica/utilities/global_methods.dart';
import 'package:clica/widgets/app_bar_back_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({super.key});

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  final TextEditingController _nameController = TextEditingController();
  File? finalFileImage;
  String userImage = "";

  @override
  void dispose() {
    _btnController.stop();
    _nameController.dispose();
    super.dispose();
  }

  void selectImage(bool fromCamera) async {
    finalFileImage = await pickImage(
      fromCamera: fromCamera,
      onFall: (String message) {
        showSnackBar(context, message);
      },
    );
    // crop image
   await cropImage(finalFileImage?.path);

   popContext();
  }
  popContext(){
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
      } else {
       // popTheDialog(); 
      }
    }
  }

  
void showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: MediaQuery.of(context).size.height / 5,
        child: Column(
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              DisplayUserImage(
                finalFileImage: finalFileImage,
                 radius: 50,
                  onPressed:(){
                showBottomSheet();
              },),
              
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: () {
                    if (_nameController.text.isEmpty || 
                        _nameController.text.length < 3) {
                      showSnackBar(context, 'Please enter your name');
                      _btnController.reset();
                      return;
                    }
                    // Save user information
                    saveUserDataToFireStore();
                  },
                  successIcon: Icons.check,
                  successColor: Colors.green,
                  errorColor: Colors.red,
                  color: Theme.of(context).primaryColor,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void saveUserDataToFireStore() async {
      final authProvider = context.read<AuthenticationProvider>();

      UserModel userModel = UserModel(
        uid: authProvider.uid!,
        name: _nameController.text.trim(),
        phoneNumber: authProvider.phoneNumber!,
        image:'',
        token: '',
        aboutMe: 'Hey there i am using clica',
        createdAt:'',
        lastSeen: '',
        isOnline: true,
        friendRequestsUIDs: [],
        friendsUIDs: [],
        sentFriendRequestsUIDs: [],
      );
      authProvider.saveUserDataToFireStore(
        userModel: userModel,
         fileImage: finalFileImage,
          onSuccess:() async {
            _btnController.success();
            // save user data to shared preferences
            await authProvider.saveUserDataToSharedPreferences();
            
            navigateToHomeScreen();
          },
           onFail:()async{
            _btnController.error();
            showSnackBar(context, 'Failed to save user data');
            await Future.delayed(const Duration(seconds: 1));
            _btnController.reset();
           });
    }
    
      void navigateToHomeScreen() {
        // navigate to home screen and remove all previous screens
        Navigator.of(context).pushNamedAndRemoveUntil(
          Constants.homeScreen,
          (route) => false,
        );
      }
}